# This has a few utility functions for GenAI in Ruby.
module LibGenai

    require 'net/http'
    require 'uri'
    require 'googleauth'
    require_relative 'gcp_auth'

    include GcpAuth


    def genai_text_predict_curl_gemini(content:, model_id: , opts: {})
      opts_debug = opts.fetch :debug, false
      opts_max_content_size = opts.fetch :max_content_size, -1
      opts_verbose = opts.fetch :verbose, false
      opts_temperature = opts.fetch :temperature, false

      project_id, access_token = gcp_project_id_and_access_token()
      api_url = "https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/#{model_id}:streamGenerateContent"
      #api_url = "https://us-central1-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/us-central1/publishers/google/models/${MODEL_ID}:streamGenerateContent"

      # If I dont truncate, I get consistent errors. Possibly due to limitation in input tokens for the API.
      if opts_max_content_size > 0
        truncated_content = content[0, opts_max_content_size]
        puts "Truncating content to #{opts_max_content_size}B (original was #{content.size}B)" if opts_debug
      else
        truncated_content = content
        puts "Keeping original content (size: #{content.size}B)" if opts_debug
      end

      url = URI.parse(api_url)

      puts("URL: #{url}") if opts_debug

      payload_hash = {
          "contents": {
            "role": "user",
            "parts": [
              {
                "text": truncated_content
              }
            ]
          },


#          [
          #     { "content": truncated_content },
          # ],
          # "parameters": {
          #     "candidateCount": 1, # TODO(ricc): investigate having more candidates!
          #     "temperature": opts_temperature,
          #     "maxOutputTokens": 2045, # safe: 1000. Max: 2048
          #     "topP": 0.9,
          #     "topK": 40
          # }
      }

      # Create an HTTP object
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https') # Enable SSL if the URL uses 'https'

      headers = {
        'Content-Type': 'application/json' ,
        "Authorization": "Bearer #{access_token}",
      }

      # Prepare the request
      response = Net::HTTP.post(url, payload_hash.to_json, headers)

      # Check the response and handle the result
      if response.code == '200'
        puts "🟢 API Response: 200 OK" #  Response body:
        puts response.body if opts_verbose

        json_body = JSON.parse(response.body)
        puts("json_body Class: ", json_body.class)
        puts("json_body arra length: ", json_body.length)
        # DEBUG
        #File.open('.tmp.gemini-response.json', 'w') { |file| file.write("//DEBUG:\n#{json_body}") }
        File.open('.tmp.gemini-response.json', 'w') { |file| file.write(json_body) }
        #puts(json_body.keys)


        # this was Palm
        #the_answer = json_body['predictions'][0]['content']
        # this is Sparta!
        #the_answer = 300
        # this is GEMINI!
        the_answer = '' # json_body[0]['candidates'][0]['content']
        json_body.each do | jb1| # 39
          # Sample:
          # JB1: {"candidates"=>[{"content"=>{"role"=>"model", "parts"=>[{"text"=>" GCP documentation and a GitHub repository for managing organizational structures.\",\n            \"url\": \"https://medium.com/google-cloud/how-to-migrate-projects-across-organizations-c7e254ab90af?source=rss-b5293b9691"}]}, "safetyRatings"=>[{"category"=>"HARM_CATEGORY_HATE_SPEECH", "probability"=>"NEGLIGIBLE", "probabilityScore"=>0.103748634, "severity"=>"HARM_SEVERITY_NEGLIGIBLE", "severityScore"=>0.08314291}, {"category"=>"HARM_CATEGORY_DANGEROUS_CONTENT", "probability"=>"NEGLIGIBLE", "probabilityScore"=>0.08079154, "severity"=>"HARM_SEVERITY_NEGLIGIBLE", "severityScore"=>0.08866235}, {"category"=>"HARM_CATEGORY_HARASSMENT", "probability"=>"NEGLIGIBLE", "probabilityScore"=>0.15546274, "severity"=>"HARM_SEVERITY_NEGLIGIBLE", "severityScore"=>0.078078166}, {"category"=>"HARM_CATEGORY_SEXUALLY_EXPLICIT", "probability"=>"NEGLIGIBLE", "probabilityScore"=>0.070176296, "severity"=>"HARM_SEVERITY_NEGLIGIBLE", "severityScore"=>0.084341794}]}]}
          #
          #puts("JB1.A: #{jb1}")
          cleaned_up_nth_response = jb1['candidates'][0]['content']['parts'][0]['text']
          puts("JB1.B: cleaned_up_nth_response: #{cleaned_up_nth_response}")
          puts("JB1.C: candidates size (should be 1, if not we need JB2): #{ jb1['candidates'].length }")
          puts("JB1.d: Keys: #{jb1.keys}")
          the_answer << cleaned_up_nth_response  # + "\n?"
        end
        #puts("Candidate length: #{json_body[0]['candidates'].length}")

        #  "usageMetadata"=>{"promptTokenCount"=>6803, "candidatesTokenCount"=>2070, "totalTokenCount"=>8873}}
        tk_data =  json_body['usageMetadata']['tokenMetadata'] rescue nil
        input_tokens = tk_data['inputTokenCount']['totalTokens'] rescue 42 #  # totalTokens in input
        output_tokens = tk_data['outputTokenCount']['totalTokens'] rescue 43 #  # totalTokens in output
        total_tokens = input_tokens + output_tokens # TODO use totalTokenCount instead
        puts "🎟️ TotalTokens: #{input_tokens} IN + #{output_tokens} OUT -> #{total_tokens} TOTAL (API_MAX=8192)"
        return the_answer
      else
        puts "🔴 API Request failed: #{response.code}"
        puts "#{response.code} Error message: #{response.message}"
        #puts response.inspect
        puts response.body # .error
        return nil
      end
    end




    # return :TODO
    # end


    # Returns authenticated response for GenAI text backend
    def genai_text_predict_curl(content:, model_id: , opts: {})
      opts_debug = opts.fetch :debug, false
      opts_max_content_size = opts.fetch :max_content_size, -1
      opts_verbose = opts.fetch :verbose, false
      opts_temperature = opts.fetch :temperature, false

      if model_id =~ /gemini/
        puts("This requires Gemini...")
        return genai_text_predict_curl_gemini(content:, model_id: , opts:)
      end

      # Constants and vars
      #model_id='text-bison'
      project_id, access_token = gcp_project_id_and_access_token()
      api_url =  "https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/#{model_id}:predict"

      # If I dont truncate, I get consistent errors. Possibly due to limitation in input tokens for the API.
      if opts_max_content_size > 0
        truncated_content = content[0, opts_max_content_size]
        puts "Truncating content to #{opts_max_content_size}B (original was #{content.size}B)" if opts_debug
      else
        truncated_content = content
        puts "Keeping original content (size: #{content.size}B)" if opts_debug
      end

      url = URI.parse(api_url)

      puts("URL: #{url}") if opts_debug

      payload_hash = {
          "instances": [
              { "content": truncated_content },
          ],
          "parameters": {
              "candidateCount": 1, # TODO(ricc): investigate having more candidates!
              "temperature": opts_temperature,
              "maxOutputTokens": 2045, # safe: 1000. Max: 2048
              "topP": 0.9,
              "topK": 40
          }
      }

      # Create an HTTP object
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https') # Enable SSL if the URL uses 'https'

      headers = {
        'Content-Type': 'application/json' ,
        "Authorization": "Bearer #{access_token}",
      }

      # Prepare the request
      response = Net::HTTP.post(url, payload_hash.to_json, headers)

      # Check the response and handle the result
      if response.code == '200'
        puts "🟢 API Response: 200 OK" #  Response body:
        puts response.body if opts_verbose

        json_body = JSON.parse(response.body)
        the_answer = json_body['predictions'][0]['content']
        #puts clever_metadata_tokens()
        # "metadata": {
        #   "tokenMetadata": {
        #     "outputTokenCount": {
        #       "totalTokens": 1973,
        #       "totalBillableCharacters": 5168
        #     },
        #     "inputTokenCount": {
        #       "totalBillableCharacters": 16200,
        #       "totalTokens": 5082
        #     }
        #   }
        tk_data =  json_body['metadata']['tokenMetadata']
        input_tokens = tk_data['inputTokenCount']['totalTokens'] #  # totalTokens in input
        output_tokens = tk_data['outputTokenCount']['totalTokens'] #  # totalTokens in output
        puts "🎟️ TotalTokens: #{input_tokens} IN + #{output_tokens} OUT -> #{input_tokens+output_tokens} TOTAL (API_MAX=8192)"
        return the_answer
      else
        puts "🔴 API Request failed: #{response.code}"
        puts "#{response.code} Error message: #{response.message}"
        #puts response.inspect
        puts response.body # .error
        return nil
      end
    end




end
