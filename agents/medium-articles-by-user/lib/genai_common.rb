#module Genai::Common
# include Common
module GenaiCommon

  require 'net/http'
  require 'uri'
  require 'googleauth'
  #require "google/cloud/storage"

  def authenticate_implicit_with_adc(project_id)
    # The ID of your Google Cloud project
    # project_id = "your-google-cloud-project-id"

    ###
    # When interacting with Google Cloud Client libraries, the library can auto-detect the
    # credentials to use.
    # TODO(Developer):
    #   1. Before running this sample,
    #      set up ADC as described in https://cloud.google.com/docs/authentication/external/set-up-adc
    #   2. Replace the project variable.
    #   3. Make sure that the user account or service account that you are using
    #      has the required permissions. For this sample, you must have "storage.buckets.list".
    ###

    #require "google/cloud/storage"

    # This sample demonstrates how to list buckets.
    # *NOTE*: Replace the client created below with the client required for your application.
    # Note that the credentials are not specified when constructing the client.
    # Hence, the client library will look for credentials using ADC.
    storage = Google::Cloud::Storage.new(project_id: project_id)
    buckets = storage.buckets
    puts "Buckets: "
    buckets.each do |bucket|
      puts bucket.name
    end
    puts "Plaintext: Listed all storage buckets using ADC."
  end

  #GOOGLE_APPLICATION_DEFAULT
  #

  # Automated repsonse
  # Docs: https://cloud.google.com/vertex-ai/docs/generative-ai/start/quickstarts/quickstart-text
  def genai_text_curl(project_id, content, opts={})
    opts_temperature = opts.fetch :temperature, 0.5

    #model_id='text-bison@001'
    model_id='text-bison' # https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/text

    api_url =  "https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/#{model_id}:predict"

    url = URI.parse(api_url)

    ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||= 'ricc-genai.json'

    raise "GOOGLE_APPLICATION_CREDENTIALS missing" unless ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS')
    key_file = File.expand_path(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS'))
    puts("DEBUG: key_file = #{key_file}")

    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(key_file),
      scope: 'https://www.googleapis.com/auth/cloud-platform' # Replace with the appropriate scope if needed
    )
    puts("credentials: #{credentials}")
    token = credentials.fetch_access_token!
    #puts("token: #{token}")
    puts("token.access_token starts with: #{ token.fetch('access_token')[0,5] }") #

    # credentials = Google::Auth.get_application_default(
    #   'https://www.googleapis.com/auth/cloud-platform'
    # )

    payload_hash = {
      "instances": [
        { "content": content },
      ],
      "parameters": {
          "temperature": opts_temperature,
          "maxOutputTokens": 1000,
          "topP": 0.8,
          "topK": 40
      }
    }

    # Create an HTTP object
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https') # Enable SSL if the URL uses 'https'

    headers = {
      'Content-Type': 'application/json' ,
      "Authorization": "Bearer #{token.fetch('access_token')}",
    }
    #credentials.apply(headers)

    #puts("Headers after creds: #{headers}")
    # Prepare the request
    response = Net::HTTP.post(url, payload_hash.to_json, headers)

    # Apply the access token to the request's authorization header
    #credentials.apply!(request)
    #puts("Request after applying creds: #{request}")
    # Send the request and receive the response
    #response = http.request(request)

    # Check the response and handle the result
    if response.code == '200'
      puts "Request succeeded!"
      puts "Response body:"
      puts response.body

      json_body = JSON.parse(response.body)
      the_answer = json_body['predictions'][0]['content']
      return the_answer
    else
      puts "Request failed with code: #{response.code}"
      puts "Error message: #{response.message}"
      return nil
    end
    #return response.body.fetch
  end


  def complete_genai_text_curl(project_id, model_id, content, opts={})
      #opts_temperature = opts.fetch :temperature, 0.5
      api_url =  "https://us-central1-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/us-central1/publishers/google/models/#{model_id}:predict"

      url = URI.parse(api_url)

      puts('TODO Riccardo harmonize this code with the vision one which uses a nice function to get the token - justr abstract thje dftl ADC for this program')
      ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||= 'ricc-genai.json'

      raise "GOOGLE_APPLICATION_CREDENTIALS missing" unless ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS')
      key_file = File.expand_path(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS'))

      puts("DEBUG: key_file = #{key_file}")

      credentials = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(key_file),
        scope: 'https://www.googleapis.com/auth/cloud-platform' # Replace with the appropriate scope if needed
      )
      puts("credentials: #{credentials}")
      token = credentials.fetch_access_token!
      puts("token: #{token}")
      puts("token AT: #{ token.fetch('access_token') }")

      # credentials = Google::Auth.get_application_default(
      #   'https://www.googleapis.com/auth/cloud-platform'
      # )

      payload_hash = {
        "instances": [
          { "content": content },
        ],
        "parameters": {
            "temperature":  0.5,
            "maxOutputTokens": 1000,
            "topP": 0.8,
            "topK": 40
        }
      }

      # Create an HTTP object
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https') # Enable SSL if the URL uses 'https'

      headers = {
        'Content-Type': 'application/json' ,
        "Authorization": "Bearer #{token.fetch('access_token')}",
      }
      #credentials.apply(headers)

      #puts("Headers after creds: #{headers}")
      # Prepare the request
      response = Net::HTTP.post(url, payload_hash.to_json, headers)
      return [payload_hash, response]
      # Apply the access token to the request's authorization header
      #credentials.apply!(request)
      #puts("Request after applying creds: #{request}")
      # Send the request and receive the response
      #response = http.request(request)

    #   # Check the response and handle the result
    #   if response.code == '200'
    #     puts "Request succeeded!"
    #     puts "Response body:"
    #     puts response.body

    #     json_body = JSON.parse(response.body)
    #     the_answer = json_body['predictions'][0]['content']
    #     return the_answer
    #   else
    #     puts "Request failed with code: #{response.code}"
    #     puts "Error message: #{response.message}"
    #     return nil
    #   end
    #   #return response.body.fetch
    end

end

# To use: include Genai::Common

#  gcloud config configurations activate ricc-genai-codelabba             ricc-genai-codelabba
# rails c
# include GenaiCommon
# genai_text_curl Rails.application.credentials.gcp.genai_project_id , 'ciao'

def gcp_token()
  key_file = File.expand_path(ENV.fetch('GOOGLE_APPLICATION_CREDENTIALS'))
  puts("DEBUG: key_file = #{key_file}")

  credentials = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(key_file),
    scope: 'https://www.googleapis.com/auth/cloud-platform' # Replace with the appropriate scope if needed
  )
  puts("credentials: #{credentials}")
  token = credentials.fetch_access_token!
  token
end


def complete_genai_image_curl(project_id, model_id, content, opts={})
  require_relative './genai/aiplatform_image_curl'
  extend Genai::AiplatformImageCurl
  opts[:project_id] = project_id
  # assert model_id is 001, 002, 003..
  # As of 22aug23 , only 002 works.
  ENV['GOOGLE_APPLICATION_CREDENTIALS'] ||= 'ricc-genai.json'

  ai_curl_images_by_content_v2(model_id, content, opts )
  
end