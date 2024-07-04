#!/usr/bin/env python3

import json

from google.cloud import bigquery
import datetime
import hashlib  # For generating the hash


#DEBUG = False
DEBUG = True
ProjectId = 'ose-volta-dev' # ()
#ProjectId = 'ose-volta-prod'

# Updated BigQuery schema
schema = [
    bigquery.SchemaField("title", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("summary", "STRING", mode="NULLABLE"),
    bigquery.SchemaField("url", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("categories", "STRING", mode="REPEATED"),
    bigquery.SchemaField("is_gcp", "BOOLEAN", mode="REQUIRED"),
    bigquery.SchemaField("is_technical", "BOOLEAN", mode="REQUIRED"),
    # New fields:
    bigquery.SchemaField("user_email", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("calculated_at", "TIMESTAMP", mode="REQUIRED"),
    bigquery.SchemaField("custom_hash", "STRING", mode="NULLABLE")  # JSON as string
]


def deb(str):
    if DEBUG:
        print(str)

# def load_json_from_file_old(file_path):
#     """Loads JSON data from a file, handling potential extra lines and returns a dictionary."""
#     try:
#         with open(file_path, 'r') as json_file:
#             lines = json_file.readlines()

#         print(f"First line: {lines[0]}\n")

#         # Check and remove potential extra lines at the beginning and end
#         if lines and lines[0].strip() == '{':
#             print(f"First line error: {lines[0].strip()}")
#             lines = lines[1:]  # Remove first line
#         if lines and lines[-1].strip() == '}':
#             lines = lines[:-1]  # Remove last line

#         data = json.loads("".join(lines))  # Load JSON from combined lines
#         return data
#     except FileNotFoundError:
#         print(f"File not found: {file_path}")
#         return None
#     except json.JSONDecodeError:
#         print(f"Error decoding JSON in file: {file_path}")
#         return None # expand_more

def load_json_from_file(file_path):
    """Loads JSON data from a file, handling potential extra lines, and returns a dictionary."""
    try:
        with open(file_path, 'r') as json_file:
            lines = json_file.readlines()

        # Check and remove first line if it matches "```json"
        if lines and lines[0].strip() == "```json":
            deb(f"First line error: {lines[0].strip()}. REMOVING")
            lines = lines[1:]

        # Check and remove last line if it matches "```"
        if lines and lines[-1].strip() == "```":
            deb(f"Last line error: {lines[-1].strip()}. REMOVING")
            lines = lines[:-1]

        data = json.loads("".join(lines))  # Load JSON from combined lines
        return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None
    except json.JSONDecodeError:
        print(f"Error decoding JSON in file: {file_path}")
        return None

def load_article_data_into_bq(metadata_dict, articles_dict):
    # Construct the rows to insert
    client = bigquery.Client(project=ProjectId)

    table_id = f"{ProjectId}.ose_colta_insights.medium_articles_data"

    # Construct the rows to insert
    rows_to_insert = []
    calculated_at = datetime.datetime.now()

    for article in articles_dict['articles_feedback']:
        # Create the custom hash
        custom_hash = hashlib.md5(json.dumps(article, sort_keys=True).encode()).hexdigest()

        # Create the row dictionary and add it to rows_to_insert
        row = article.copy()
        row['user_email'] = metadata_dict.get('user_email', "unknown_user") # Get email or use default
        row['calculated_at'] = calculated_at.strftime("%Y-%m-%d %H:%M:%S.%f") # TODO fix
        row['custom_hash'] = custom_hash  # Convert to string

        rows_to_insert.append(row)

    errors = client.insert_rows_json(table_id, rows_to_insert)  # Insert rows

    if errors == []:
        print("New rows have been added.")
    else:
        print("Encountered errors while inserting rows: {}".format(errors))


def main():
    # Replace with the actual paths to your JSON files
    metadata_file_path = "inputs/medium-latest-articles.palladiusbonton.metadata.json"
#    articles_file_path = "inputs/medium-latest-articles.palladiusbonton.txt.json"
    articles_file_path = "inputs/medium-latest-articles.palladiusbonton.txt.cleaned.json"

    # Load data into dictionaries
    metadata_dict = load_json_from_file(metadata_file_path)
    articles_dict = load_json_from_file(articles_file_path)

    # Check if loading was successful
    if metadata_dict and articles_dict:
        print("Metadata:")
        print(metadata_dict)

        print("\nArticles:")
        print(articles_dict)
    else:
        print("Error loading JSON data. Please check the file paths and contents.")


if __name__ == "__main__":
    print("ciao da python")
    main()



