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
        "https://medium.com/google-cloud/kubernetes-101-pods-nodes-containers-and-clusters-c1509e409e16",
    ]

    def parse(self, response):
        # Extract data here (e.g., article title, text, author)
        author_name = response.xpath("//a[@data-testid='authorName']/text()").get()
        # UGLY author_profile_link = response.xpath("//a[@data-testid='authorName']/@href").get()
        published_time = response.xpath("//meta[@property='article:published_time']/@content").get()

    # <meta data-rh="true" property="article:published_time" content="2024-05-28T05:15:52.024Z">
        meta = 42
        yield {
            # af ag ah ai aj ak al am an ao ap aq ar hq
#            <a class="af ag ah ai aj ak al am an ao ap aq ar hq" data-testid="authorName" rel="noopener follow" href="/@iromin?source=post_page-----9b7fd8ae031b--------------------------------">Romin Irani</a>
            "author_name": author_name,
            "published_time": published_time,
            # UGLY "author_profile_link": author_profile_link,

            "title":  response.css("h1::text").get(),
            "content": response.css("article p::text").getall(),

        }
    # def parse(self, response):
    #     print(f"🐤🐤🐤🐤🐤🐤 response 🐤🐤🐤🐤🐤🐤🐤🐤")
    #     # Extract data here (e.g., article title, text, author)
    #     MediumArticles = response.xpath("//h2/a") # .getall()
    #     #MediumArticles = response.xpath('//h2/a/@href').getall()
    #     print(f"🐤🐤 MediumArticles 🐤🐤: {MediumArticles}")
    #     for oggettone in MediumArticles:

    #              #"title_onlyone": 'sobenme',
    #              #"oggettone": oggettone,
    #         name =  oggettone.xpath(".//text()")
    #     print(f"🐤🐤 name 🐤🐤: {name}")

    #     yield {
    #         "name": name,
    #     }

        # for url in MediumArticles:
        #     yield scrapy.Request(url, callback=self.parse_only_one)
        # yield {
        #     "title_onlyone": response.css("h2::text").get(),
        #     "text": response.css("article p::text").getall(),
        #     # ...
        # }
