#!/usr/bin/env ruby

require 'net/http'
require 'nokogiri'
require 'action_view'
require 'googleauth'

require_relative 'lib/lib_genai'
require_relative 'lib/gcp_auth'#
# Has all prompt info, Temperature and so on..
require_relative 'lib/prompt'

# Max size you can ingest from XML input.
# Safe value: 16000
# Ricc got errors with this: 32000
# With 30k it works, but then the output is VERY small. Better to save some for output as total size is 32k (I believe).
MaxByteInputSize = 50000

DENY_LISTED_TITLES = [
    "Insights on Medium articles with GenAI and Ruby!",
]

#             #model_id: 'text-bison',
ModelName = "gemini-1.5-flash"

def init()
    Dir.mkdir('inputs/') rescue nil
    Dir.mkdir('outputs/') rescue nil
end

# Monkey patching File class - I love Ruby!
class File
    def writeln(str); write(str+"\n"); end
end
class IO
    def writeln(str); write(str+"\n"); end
end

def fetch_from_medium(medium_user, _opts={})
    opts_refetch_if_exists = _opts.fetch :refetch_if_exists, false

    xml_filename = "inputs/medium-feed.#{medium_user}.xml"
    genai_input_filename = "inputs/medium-latest-articles.#{medium_user}.txt"

    if File.exist?(genai_input_filename) and (not opts_refetch_if_exists )
        puts "File '#{genai_input_filename}' already exists.. wont reparse"
        return nil
    end

    # Downloading the file and iterating through article parts.
    medium_url = "https://medium.com/feed/@#{medium_user}"
    xml_response = Net::HTTP.get(URI(medium_url))
    File.open(xml_filename, 'w') do |f|
        f.write xml_response
    end
    # deprecated
    #publications = "https://api.medium.com/v1/users/#{medium_user}/publications?format=json"
    docSM = Nokogiri::XML(xml_response)

    num_items = docSM.xpath("//item").count

    puts("#Article items: #{num_items}")

    # Looks like my articles are under many <content:encoded> tags, so here you go..
    File.open(genai_input_filename, 'w') do |file| # file.write("your text") }
        ## Version 2: Scrape more important metadatsa

        # To change from fkile to stdout, uncomment the following line :)
        #file = $stdout

        docSM.xpath("//item").each_with_index do |node,ix| # Article
            title = node.xpath("title").inner_text
            creator = node.xpath("dc:creator").inner_text
            url =  node.xpath("link").inner_text
            pubDate =  node.xpath("pubDate").inner_text
            categories =  node.xpath("category").map{|c| c.inner_text}  # there's many, eg:  ["cycling", "google-forms", "data-studio", "pivot", "google-sheets"]
            article_content = ActionView::Base.full_sanitizer.sanitize(node.xpath('content:encoded').inner_text)[0, ArticleMaxBytes]

            #if title.in?(DENY_LISTED_TITLES)
            if DENY_LISTED_TITLES.include? title
                puts "❗ DENYLISTED TITLE, skipping: #{title}"
                next
            end
            file.writeln "\n== Article #{ix+1}"
            file.writeln "* Title: '#{title}'"
            file.writeln "* Author: '#{creator}'"
            file.writeln "* URL: '#{url}'"
            file.writeln "* PublicationDate: '#{pubDate}'"
            file.writeln "* Categories: #{categories.join(', ')}"
            file.writeln ""
            #file.writeln(node.to_s) # .inner_text   # LONG version
            file.writeln article_content    # SANITIZED version
        end

    end
    #exit 42
    return true
end

def call_api_for_single_user(medium_user)
    call_api_for_all_texts(single_user: medium_user)
end

def call_api_for_all_texts(_opts={})
    opts_overwrite_if_exists = _opts.fetch :overwrite_if_exists, false
    opts_single_user = _opts.fetch :single_user, nil

    Dir.glob("inputs/medium-latest-articles.*.txt") do |my_text_file|
        if opts_single_user
            #puts "DEB REMOVEME my_text_file: #{my_text_file}"
            next unless my_text_file == "inputs/medium-latest-articles.#{opts_single_user}.txt"
        end
        puts "Working on: #{my_text_file}..."
        output_file = "outputs/" + my_text_file.split('/')[1] + '.json'
        #genai_input = PromptInJson + "\n" + File.read(my_text_file) + "\n\nJSON:\n"
        genai_input = build_prompt_from_file(my_text_file) # PromptInJson + "\n" + File.read(my_text_file) + "\n\nJSON:\n"

        if opts_overwrite_if_exists and File.exist?(output_file)
            puts "File exists, skipping: #{output_file}"
            next
        end

        include LibGenai

        output = genai_text_predict_curl(
            content: genai_input,
            model_id: ModelName, # "gemini-1.5-flash",
            opts: {
                max_content_size: MaxByteInputSize,
                verbose: false,
                temperature: Temperature
            })
        File.open(output_file, 'w') do |f|
            f.write output
        end
        puts "💾 File written on: #{output_file}) "
        # https://stackoverflow.com/questions/42385036/validate-json-file-syntax-in-shell-script-without-installing-any-package
        valid_json_script = `cat '#{output_file}' | json_pp`
        ret = $?
        puts "✔️ Valid JSON? => #{ret}"

        #exit 42
        # Call API for summarization: https://cloud.google.com/vertex-ai/docs/generative-ai/text/summarization-prompts
    end
end

def add_metadata_per_user(medium_user, user_email)
    puts("Medium User:       #{medium_user}")
    puts("user_email: #{user_email}")
    metadata_output_file = "outputs/medium-latest-articles.#{medium_user}.metadata.json"
    metadata = {
        user_email: user_email,
        medium_user: medium_user,
        timestamp: Time.now,
        genai_model: ModelName,
        max_byte_input_size: MaxByteInputSize,
        PromptVersion: PromptVersion,
        ArticleMaxBytes: ArticleMaxBytes,
        temperature: Temperature, # doesnt work yetc
        comments: "Temperature isnt functional yet, I just ported from Palm to Gemini this morning",
    }
    File.open(metadata_output_file, 'w') do |f|
        f.write metadata.to_json
    end
end

def alles_gut(medium_user)
    # making sure the LAST action touches a file which says all good
    `touch outputs/medium-latest-articles.#{medium_user}.ok.touch`
end

def main()
    init()
    medium_user = ENV.fetch 'MEDIUM_USER_ID', 'palladiusbonton'
    #user_email = (ENV.fetch 'LDAP', 'nobody') + '@google.com'
    ldap = ENV.fetch 'LDAP', nil
    user_email = ldap ? "#{ldap}@google.com" : 'nobody@example.com'
    puts "Fetching from the internet Medium User: '#{medium_user}'"
    add_metadata_per_user(medium_user, user_email)

    fetch_from_medium(medium_user)
    call_api_for_single_user(medium_user)

    # finnally
    alles_gut(medium_user)
end

main()
