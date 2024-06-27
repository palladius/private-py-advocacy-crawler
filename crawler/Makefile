
install:
	pip install -r requirements.txt

#run-clean: clean run

run-single-medium-pages:
	scrapy runspider medium_single_article.py -o medium_single_articles.jsonl
# cat medium_single_articles.jsonl | lolcat

run-old:
# hard to implement
	#scrapy runspider gcp_spider.py -o gcp_articles.jsonl
	scrapy runspider medium_multiple_articles_from_user_pages_spider.py -o medium_multiple_articles_from_user_pages.jsonl
	#cat gcp_articles.jsonl | lolcat

test-quotes:
	scrapy runspider quotes_spider.py -o quotes.jsonl

# test-books:
# 	scrapy runspider books_spider.py -o books.jsonl
clean:
	rm gcp_articles.jsonl
