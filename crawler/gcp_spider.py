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
        # Medium Start
        "https://medium.com/@palladiusbonton",
       # "https://iromin.medium.com/",
        # https://medium.com/google-cloud/a-tale-of-two-functions-function-calling-in-gemini-9b7fd8ae031b?source=user_profile---------2----------------------------
        # ...
    ] # Add your starting URLs

    def parse_only_one(self, response):
        # Extract data here (e.g., article title, text, author)
        yield {
            "title_onlyone": response.css("h2::text").get(),
            "text": response.css("article p::text").getall(),
            # ...
        }
    def parse(self, response):
        print(f"🐤🐤🐤🐤🐤🐤 response 🐤🐤🐤🐤🐤🐤🐤🐤")
        # Extract data here (e.g., article title, text, author)
        MediumArticles = response.xpath("//h2/a") # .getall()
        #MediumArticles = response.xpath('//h2/a/@href').getall()
        print(f"🐤🐤 MediumArticles 🐤🐤: {MediumArticles}")
        for oggettone in MediumArticles:

                 #"title_onlyone": 'sobenme',
                 #"oggettone": oggettone,
            name =  oggettone.xpath(".//text()")
        print(f"🐤🐤 name 🐤🐤: {name}")

        yield {
            "name": name,
        }

        # for url in MediumArticles:
        #     yield scrapy.Request(url, callback=self.parse_only_one)
        # yield {
        #     "title_onlyone": response.css("h2::text").get(),
        #     "text": response.css("article p::text").getall(),
        #     # ...
        # }
