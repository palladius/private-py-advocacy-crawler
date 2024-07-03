# Function handler in main.rb
require 'functions_framework'

FunctionsFramework.http 'my_function' do |request|
  # Your code here
  name = request.params['name'] || 'World'
  "Hello, #{name}!"
end



FunctionsFramework.http 'parse_latest_medium_articles_by_username' do |request|
  # Your code here
  username = request.params['username'] || 'palladiusbonton'
  "Hello, #{username}! I'm going to parse this person Medium XML file and then return a nice JSON array with all necessary stuff"
end
