#!/usr/bin/env python3




import json

def load_json_from_file(file_path):
    """Loads JSON data from a file and returns a dictionary."""
    try:
        with open(file_path, 'r') as json_file:
            data = json.load(json_file)
        return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return None
    except json.JSONDecodeError:
        print(f"Error decoding JSON in file: {file_path}")
        return None # expand_more


def main():
    # Replace with the actual paths to your JSON files
    metadata_file_path = "inputs/medium-latest-articles.palladiusbonton.metadata.json"
    articles_file_path = "inputs/medium-latest-articles.palladiusbonton.txt.json"

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



