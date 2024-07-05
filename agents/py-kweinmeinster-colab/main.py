#!/usr/bin/env python

#import IPython
import time

#app = IPython.Application.instance()
#app.kernel.do_shutdown(True)

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


def main():
    print("Welcome to Karl notebook transformed into a python script..")
    model = GenerativeModel("gemini-1.0-pro")

    csv_file_path = './January.csv'

    df = pd.read_csv(csv_file_path)
    print(df.head())

    df['Contents'] = df['URL'].apply(extract_text_from_url)

    print(df.head())





if __name__ == "__main__":
    main()
