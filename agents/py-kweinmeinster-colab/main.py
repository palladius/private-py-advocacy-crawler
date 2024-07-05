#!/usr/bin/env python

'''
This script is inspired in primis by Karl Notebook.

I've also found this useful:
* https://pureai.com/Articles/2023/12/20/try-gemini.aspx To get GEmini config
'''

#import IPython
import time
import gspread
from bs4 import BeautifulSoup
import pandas as pd
import plotly.express as px
import requests
from vertexai.generative_models import (
    GenerationConfig,
    GenerativeModel,
    Image,
    Part
)
# https://pureai.com/Articles/2023/12/20/try-gemini.aspx
from prompt import flywheel_stage_prompt_header, flywheel_stage_prompt_footer



GeminiModel = 'gemini-1.5-pro'
CallGemini  = False
CallCurls = False
TrixTitle = '[ose-volta-dev] Karl results' # https://docs.google.com/spreadsheets/d/1OlOaE_KcMa6EKCAJAtQs7APGfVV4cy6n2PWLJA6geBY/edit?gid=0&resourcekey=0-JCHsxIAgySvLoUQLOCDfng#gid=0
#GeminiModel = "gemini-1.0-pro"


def extract_text_from_url(url):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Check for HTTP errors

        soup = BeautifulSoup(response.content, 'html.parser')

        text = soup.get_text(strip=True, separator=" ")

        return text
    except requests.exceptions.RequestException as e:
        print(f"Error for URL {url}: {e}")
        return None

def classify_content(prompt_header,prompt_footer, content_type, title, url, contents, model):
    if contents is None:
      contents = ''
    combined_prompt = f"{prompt_header}\n\nContent Type: {content_type}\nTitle: {title}\nURL: {url}\nContents: {contents}\n\n{prompt_footer}"
    ##print(combined_prompt)

    # hinted by https://pureai.com/Articles/2023/12/20/try-gemini.aspx
    generation_config = GenerationConfig(
            stop_sequences = None,
            temperature=0.2,
            # top_p=1.0,
            # top_k=32,
            candidate_count=1,
            max_output_tokens=4,
            )
    response = model.generate_content(combined_prompt,
                                    #   max_output_tokens=12,
                                    #   candidate_count=1,
                                    #   stop_sequences = None,
                                    #   temperature=0.3,
                                      generation_config=generation_config,
                                      stream=False).text.strip()
    print(f"[DEBUG][model={GeminiModel}] Flywheel Status: '{response}'")
    return response


def write_onto_spreadsheet(df):
    '''auth is hard here. NEeds a SvcAcct.
    '''
    gc = gspread.service_account()

    print("TODO auth")
    sh = gc.open('My poor gym results')
    exit(42)


def main():
    print("Welcome to Karl notebook transformed into a python script..")

    model = GenerativeModel(GeminiModel)
    print(model)

    csv_file_path = './January-dev.csv'

    df = pd.read_csv(csv_file_path)
    print(df.head())


    if CallCurls:
        print('Calling Curls => expect some latency')
        df['Contents'] = df['URL'].apply(extract_text_from_url)
        print(df.head())

    if CallGemini:
        print('Calling Gemini => expect latency to kick in and maybe also exaust API calls.')

        df['Flywheel Stage - Gemini'] = df.apply(lambda row: classify_content(flywheel_stage_prompt_header,flywheel_stage_prompt_footer, row['Content Type'], row['Title'], row['URL'], row['Contents'], model), axis=1)

        print(df.head())

    write_onto_spreadsheet(df)


    print('The end')



if __name__ == "__main__":
    main()
