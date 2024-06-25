# main.py


import scrapy

class GcpContentSpider(scrapy.Spider):
    name = "gcp_content"
    allowed_domains = [
        "medium.com",
        #"youtube.com",
        #"yourblog.com",
        ]  # Add your domains
    start_urls = [
        "https://medium.com/google-cloud/a-tale-of-two-functions-function-calling-in-gemini-9b7fd8ae031b",
        "https://medium.com/@palladiusbonton/hey-bard-write-a-responsive-javascript-search-engine-app-for-me-b2585e55385e",
        "https://medium.com/google-cloud/gemma-is-born-c5ea9ba576ec",
        #"https://blog.devops.dev/comand-line-rag-with-ruby-bash-and-gemma-curling-a-website-without-apis-de69215d43df",
        #"https://medium.com/google-cloud/kubernetes-101-pods-nodes-containers-and-clusters-c1509e409e16",
    ]

    def parse(self, response):
        # Extract data here (e.g., article title, text, author)
        author_name = response.xpath("//a[@data-testid='authorName']/text()").get()
        content = response.css("article p::text").getall(),
        # UGLY author_profile_link = response.xpath("//a[@data-testid='authorName']/@href").get()
        published_time = response.xpath("//meta[@property='article:published_time']/@content").get()
        twitter_creator = response.xpath("//meta[@property='twitter:creator']/@content").get()


     #      claps = //div[@class='bl']//button/text()
    # <meta data-rh="true" property="article:published_time" content="2024-05-28T05:15:52.024Z">
        #claps1 = int(response.xpath("//div[@class='bl']//button/text()").get())
        # claps2 = response.xpath("//div[@class='bl']//button/text()").get()
        # claps3 = response.xpath("//p[contains(@class, 'be b dx z dw')]//button/text()").get()
        # claps4 = response.xpath("//div[@class='pw-multi-vote-count l kl km kn ko kp kq kr']//button/text()").get()
        # claps5 = response.xpath("//div[@class='pw-multi-vote-count']//button/text()").get()
        # claps6 = response.xpath("//div[@class='pw-multi-vote-count']//button/text()").get()
        # claps7 = response.xpath("//button[@aria-label='claps']/text()").get()
        # claps8 = response.xpath("//button[contains(@class, 'af ag ah ai aj ak al am an ao ap aq ar as at uw ux')]/text()").get()
        claps9 = response.xpath("//div[@class='bl']//button/text()").get()

        title = response.css("h1::text").get()

        twitter_username = response.xpath("//meta[@name='twitter:creator']/@content").get()
        twitter_image = response.xpath("//meta[@name='twitter:image:src']/@content").get()

        keywords = response.xpath("//div[@class='pr ps ab ib']//a/div/text()").getall()

        keyword2 = response.xpath('//a[@class="pu ax am ao"]/div/text()').getall()

        keyword3 = response.xpath("//div[contains(@class, 'ch bg eu ev ew ex')]//a/div/text()").getall()

        keyword_hrefs = response.xpath("//div[contains(@class, 'ch bg eu ev ew ex')]//a/@href").getall()


        yield {
            "author_name": author_name,
            "published_time": published_time,
            "title": title,
            "twitter_creator": twitter_username,
            "twitter_image": twitter_image,
            "content": content,
            # "keywords": keywords,
            # "keyword2": keyword2,
            # "keyword3": keyword3,
            # "keyword_hrefs": keyword_hrefs,
        }
