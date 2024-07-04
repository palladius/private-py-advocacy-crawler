
require 'yaml'

ConfigFile = "../../etc/cloud-devrel.yaml"
# Load the YAML data
data = YAML.load_file(ConfigFile)

puts("# You can just type the output into '| bash' :)")



# Iterate through each domain and its teams
data.each do |domain, teams|
  puts("# Domain: #{domain}")
  teams.each do |team_name, members|
    members.each do |username, info|
      medium_handle = info['medium']

      # Execute the script if medium_handle exists
      if medium_handle
        #system("./script.sh #{username} #{medium_handle}")
        #puts("./script.sh user=#{username} medium=#{medium_handle}")
        puts("LDAP='#{username}' MEDIUM_USER_ID='#{medium_handle}' ruby main.rb") if domain == 'google.com'
      end
    end
  end
end
