#!/usr/bin/env python

'''Parses go/ricc-advocacy-ideas trix for advocacy info.
'''
import gspread
import yaml
# for comments use https://pypi.org/project/ruamel.yaml/
# https://stackoverflow.com/questions/13517753/adding-comments-to-yaml-produced-with-pyyaml

def read_from_spreadsheet(trix_title):
    '''Reads file onto CSV

    gc = gspread.service_account() looks for file in ... ~/.gspread/

    '''
    # move to CSV...
    gc = gspread.service_account()
    sh = gc.open(trix_title)
    devrellers_range = 'A1:K50'  # see https://docs.google.com/spreadsheets/d/1wTxnAZrJNcPTwFDoURUxGWPqsIHqytFyNfW63KNtGVU/edit?gid=0#gid=0
    #sh = gc.open('go/ricc-advocacy-ideas')
    #sh = gc.open_by_key('1wTxnAZrJNcPTwFDoURUxGWPqsIHqytFyNfW63KNtGVU')

    worksheet = sh.worksheet("DevRellers")
#    worksheet_list = sh.worksheets()
#    print(f"List of worksheets: {worksheet_list}")

    print('Spreadsheet READ test: lets output the value of A1:')
    print(sh.sheet1.get(devrellers_range))

    return sh.sheet1.get(devrellers_range)

# Dump looks like this:
# ajahammerly:
#   Fancy Name: Aja Hammerly
#   Github User: thagomizer
#   Official Parsable Blog: https://thagomizer.com/
# alexismp:
#   Fancy Name: Alexis Moussine-Pouchkine
# colton: {}
# deleplace:
#   Fancy Name: Valentin Deleplace
#   Github User: deleplace
# def dump_on_yaml(data, filename="devreller_data.yaml"):
#     # Creating the yaml dictionary
#     yaml_dict = {}
#     for row in data:
#         key = row[0]
#         fields = {}

#         # Skip empty fields and the last "ObscureJson" field
#         for i in range(1, len(row) - 1):
#             if row[i]:
#                 fields[data[0][i]] = row[i]

#         yaml_dict[key] = fields

#     # Writing to YAML
#     yaml_filename = filename # "devreller_data.yaml"

#     try:
#         with open(yaml_filename, "w") as yaml_file:
#             yaml.dump(yaml_dict, yaml_file, default_flow_style=False, sort_keys=False)
#         print(f"YAML file '{yaml_filename}' created successfully.")

#     except (IOError, yaml.YAMLError) as e:
#         print(f"Error creating YAML file: {e}")
def dump_on_yaml(data, yaml_filename="../../etc/devreller_data_from_trix.yaml"):
    # Creating the yaml dictionary
    yaml_dict = {}

    data_without_headers = data[1:]
    #key = data[0]

    for row in data_without_headers:
        key = row[0] # ldap
        # print(f"[DEB] ldap={key}")
        fields = {}

        # Skip empty fields and the last "ObscureJson" field
        # if key == 'kotwal' or key == 'ianlewis':
        #     print(f"DEB row size={len(row)}: {row}")
        for i in range(1, len(row) ):
            # if key == 'kotwal' or key == 'ianlewis':
            #     print(f"DEB Row X {i} column {i} ({data[0][i]}): {row[i]}")
            if row[i]:
                fields[data[0][i]] = row[i]
            # else:
            #     if key == 'kotwal' or key == 'ianlewis':
            #         print(f"DEB no value for row[{i}]: {row[i]}")

        yaml_dict[key] = fields


    # Writing to YAML
    #yaml_filename = filename # "devreller_data.yaml"
    enriched_yaml_dict = { 'google.com': yaml_dict }

    try:
        with open(yaml_filename, "w") as yaml_file:
            yaml.dump(enriched_yaml_dict, yaml_file, default_flow_style=False, sort_keys=False)
        print(f"YAML file '{yaml_filename}' created successfully.")

    except (IOError, yaml.YAMLError) as e:
        print(f"Error creating YAML file: {e}")


def main():
    aoa = read_from_spreadsheet('go/ricc-advocacy-ideas')
    dump_on_yaml(aoa)


if __name__ == "__main__":
    main()
