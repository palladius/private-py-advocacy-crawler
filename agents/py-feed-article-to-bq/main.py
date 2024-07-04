#!/usr/bin/env python3

import json

from google.cloud import bigquery
import datetime
import zoneinfo # fot TZ
import hashlib  # For generating the hash

timezone_utc = zoneinfo.ZoneInfo('UTC')


#DEBUG = False
DEBUG = True
#ProjectId = 'ose-volta-dev' # ()
#Dataset = 'ose_volta_insights'
#ProjectId = 'ose-volta-prod'

# Updated BigQuery schema
schema = [
    bigquery.SchemaField("title", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("genai_summary", "STRING", mode="NULLABLE"), # genai generated
    bigquery.SchemaField("url", "STRING", mode="REQUIRED"),
    bigquery.SchemaField("categories", "STRING", mode="REPEATED"),
    bigquery.SchemaField("is_gcp", "BOOLEAN", mode="REQUIRED"),
    bigquery.SchemaField("is_technical", "BOOLEAN", mode="REQUIRED"),
    bigquery.SchemaField("user_email", "STRING", mode="REQUIRED"), # LDAP on steroids - supports also GDEs, ..
    bigquery.SchemaField("calculated_at", "TIMESTAMP", mode="NULLABLE"), # from JSON calculation
    bigquery.SchemaField("populated_at", "TIMESTAMP", mode="REQUIRED"), # from NOW (this script) - probably useless
    bigquery.SchemaField("custom_hash", "STRING", mode="NULLABLE"),  # JSON as string
    bigquery.SchemaField("genai_model", "STRING", mode="NULLABLE"),  # string. Example: "gemini-1.5-flash"
    bigquery.SchemaField("asset_type", "STRING", mode="REQUIRED"),  # Medium Article, ..
    bigquery.SchemaField("asset_type_version", "STRING", mode="REQUIRED"),  # Medium Article v1 vs v2 (if we take different prompt versions..)
    bigquery.SchemaField("publication_date", "DATE", mode="NULLABLE"),
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
    projectId = 'ose-volta-dev' # ()
    dataset = 'ose_volta_insights'
    table_basename = 'medium_articles_data'
    table_ver = '1_2' # TODO . into _

    table_name = f"{table_basename}{table_ver}"

    client = bigquery.Client(project=projectId)

    table_id = f"{projectId}.{dataset}.{table_name}"

    tables = list(client.list_tables(f"{projectId}.{dataset}"))
    table_exists = False
    for table in tables:
        if table.table_id == table_name:
            table_exists = True
            break

    if not table_exists:
        table = bigquery.Table(table_id, schema=schema)
        table = client.create_table(table)
        print(f"Created table {table.project}.{table.dataset_id}.{table.table_id}") # expand_more
    else:
        print(f"Table {table_id} already exists. No need to create.")

    # Construct the rows to insert
    rows_to_insert = []
    populated_at = datetime.datetime.now()

    fields_to_exclude = ["accuracy", "summary"] # , "asset_type", "asset_type_version"]  # Fields to filter out


    for article in articles_dict['articles_feedback']:
        # Create the custom hash
        custom_hash = hashlib.md5(json.dumps(article, sort_keys=True).encode()).hexdigest()

        # Create the row dictionary and add it to rows_to_insert
        #row = article.copy()
        ###################
        # 1. N-th Article itself info
        ###################
        row = {key: value for key, value in article.items() if key not in fields_to_exclude}
        row['genai_summary'] = article['summary']
        ###################
        # 2. metadata JSON file info
        ###################
        row['user_email'] = metadata_dict.get('user_email', None) # Get email or use default
        row['genai_model'] = metadata_dict.get('genai_model', None) # Get model used to elaborate genai stuff.
        #  "timestamp":"2024-07-04 09:07:33 +0200",
        #timestamp_for_bq =  metadata_dict.get('timestamp')
        row['populated_at'] = populated_at.strftime("%Y-%m-%d %H:%M:%S.%f") # TODO fix with actual script from ruby
        #row['populated_at'] = populated_at.strftime("%Y-%m-%d %H:%M:%S.%f") # correct

        #  sample value for timestamp:   "timestamp":"2024-07-04 09:07:33 +0200",
        #row['populated_at'] = metadata_dict.get('timestamp').strftime("%Y-%m-%d %H:%M:%S.%f") # doesnt work
        populated_at_str =  metadata_dict.get('timestamp')
        populated_at = datetime.datetime.strptime(populated_at_str, "%Y-%m-%d %H:%M:%S %z")
        populated_at_utc = populated_at.astimezone(timezone_utc)
        row['calculated_at']  = populated_at_utc.strftime("%Y-%m-%d %H:%M:%S.%f")

        print(f"calculated_at from ruby metadata file: ")
        row['custom_hash'] = custom_hash  # Convert to string
        # Constant for this program
        row['asset_type'] = 'medium-article'
        row['asset_type_version'] = f"script1.0--PromptVersionv{metadata_dict['PromptVersion']}"
        deb(f"About to append to BQ this article row: {row}")
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
        if DEBUG:
            print("[DEB] Metadata: ")
            print(metadata_dict)

            print("\n[DEB] Articles: ")
            print(articles_dict)

        load_article_data_into_bq(metadata_dict, articles_dict)
    else:
        print("Error loading JSON data. Please check the file paths and contents.")


if __name__ == "__main__":
    print("ciao da python")
    main()



