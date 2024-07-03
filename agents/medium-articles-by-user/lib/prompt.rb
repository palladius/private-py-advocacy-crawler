PromptVersion = '1.11'
#ArticleMaxBytes = 2200 # manually nitted to get right amount of tokens :)
ArticleMaxBytes = 8800 # manually nitted to get right amount of tokens :)



# 1.11 3jul24 added ```json. Increased bytes to 4x=8k. Using Gemini 1.5 flash now.
#     <copied from github to this other project>
# 1.10 13dec23 Removed song. totally useless and repetitive :)
# 1.9 4dec23  Added publication_date to articles. Incresased temperature to 0.9 (!!) since this is needed for the system to guess nationality and other fun stuff.
# 1.8 21nov23 Dropped style examples ( Is it professional or more personal? Terse or verbose? And so on) as it was always going to say prof/nonprof terse/nonterse
# 1.7 17nov23 Small nits, like parametrizing a few things. Removed movie, tried with book, removed it. Removed publication_date to make it shorter
# 1.6 16nov23 Removed typos from articles.
# 1.5 16nov23 Added movie.
# 1.4 16nov23 Moved from TXT to JSON!
# Prompt = <<-END_OF_PROMPT
# Provide a summary for each of the following articles.

# * Please write about the topics, the style, and rate the article from 1 to 10 in terms of accuracy or professionalism.
# * Please also tell me, for each article, whether it talks about Google Cloud.
# * Can you guess the nationality of the person (or geographic context of the article itself) writing all of these articles?
# * If you can find any typos or visible mistakes, please write them down.

# --

# END_OF_PROMPT

### PROMPT HISTORY
Temperature = 0.9

PromptInJson = <<-END_OF_PROMPT
You are an avid article reader and summarizer in English language.
I'm going to provide a list of articles for a single author and ask you to do the followin:

1. For each article, I'm going to ask a number of per-article questions
2. Overall, I'm going to ask questions about the author.

I'm going to provide a JSON structure for the questions I ask. If you don't know some answer, feel free to leave NULL/empty values.

1. Per-article:

* Please write about the topics, the style, and rate the article from 1 to 10 in terms of accuracy or professionalism.
* Tell me, for each article, whether it talks about Google Cloud and/or if it's technical.
* For each article, capture the original title and please produce a short 300-500-character summary.

2. Overall (author):

* Extract name and surname
* Guess the nationality of the person.
* Please describe this author style in 20 words or less.
* Does this author prefer a certain programming language? In which language are their code snippets (if any)? No frameworks, just languages.
* If you can find any typos or recurring mistakes in any article, please write them here. Not more than 3, just the most important.

Please provide the output in a `JSON` file as an array of answer per article, like this:

{
    "prompt_version": "#{PromptVersion}", // do NOT change this
    "llm_temperature": "#{Temperature}",   // do NOT change this
    "author_name": "", // name and surname of the author
    "author_nationality":  "", // nationality here
    "author_style": "",  // overall author style: is it professional or more personal? Terse or verbose? ..
    "author_favorite_languages": "blah, blah",  // which plain languages does the author use? Pascal? C++? Python? Java? Separate with commas.
    "author_favorite_cloud": "",  // which Cloud Provider does this author use, if any?
    "typos": [{ // array of mistakes or typos, maximum THREE.
            "current": "", // (STRING) typo or mistake
            "correct": ""  // (STRING) fixed typo
        }],
    "articles_feedback": [

        // article 1
        {
        "title": "",         // This should be the ORIGINAL article title, you should be able to extract it from the TITLE XML part, like "<title><![CDATA[What is toilet papers right side?]]></title>"
        "summary": "...",    // This should be the article summary produced by you.
        "url": "http://....", // Add here the article URL
        "accuracy": XXX,     // Integer 1 to 10
        "publication_date": "YYYY-MM-DD", // string, the day in which this article was published.
        "is_gcp": XXX,   // boolean, true of false
        "is_technical": XXX,   // boolean, true of false
        ]
    },

        // Article 2, and so on..
    ]
}

Make **ABSOLUTELY SURE** the result is valid JSON (and NOT markdown) or I'll have to drop the result.

Here are the articles:

--
```json

END_OF_PROMPT
