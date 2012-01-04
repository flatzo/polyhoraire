#!/usr/bin/ruby

require 'rubygems'
require 'google/api_client'
require 'yaml'

oauth_yaml = YAML.load_file('.google-api.yaml')
client = Google::APIClient.new
client.authorization.client_id = oauth_yaml["client_id"]
client.authorization.client_secret = oauth_yaml["client_secret"]
client.authorization.scope = oauth_yaml["scope"]
client.authorization.refresh_token = oauth_yaml["refresh_token"]
client.authorization.access_token = oauth_yaml["access_token"]

if client.authorization.refresh_token && client.authorization.expired?
  client.authorization.fetch_access_token!
end

service = client.discovered_api('calendar', 'v3')



page_token = nil
result = client.execute(:api_method => service.calendar_list.list)
while true
  entries = result.data.items
  entries.each do |e|
    print e.summary + "\n"
    print e.id + "\n"
  end
  if !(page_token = result.data.next_page_token)
    break
  end
  result = client.execute(:api_method => service.calendar_list.list,
                          :parameters => {'pageToken' => page_token})
end