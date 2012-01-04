require 'rubygems'
require 'google/api_client'
require 'nokogiri'
require 'yaml'

class GoogleExporter

  def initialize(xmlDoc)
    @calendar = to_calendar(xmlDoc)
    puts @calendar.to_xml.to_s
  end

  ## Using GData utility library : http://code.google.com/apis/gdata/articles/gdata_on_rails.html
  def send
    
  end
  
  def selectCalendar(idUrl)
    
  end
  
  # return : hash[:calendarID => :calendarName]
  def calendarList
    list = Hash.new
    
    page_token = nil
    result = client.execute(:api_method => service.calendar_list.list)
    while true
      entries = result.data.items
      entries.each do |e|
        list[e.id] = e.summary
      end
      if !(page_token = result.data.next_page_token)
        break
      end
      result = client.execute(:api_method => service.calendar_list.list,
                              :parameters => {'pageToken' => page_token})
    end
  end
  
  def auth
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
    
    @client = client
  end

  def auth?

  end
  
  private 
  
  def to_calendar(xmlDoc)
    xsl = Nokogiri::XSLT(File.read(Poly::XSLDocs[:exportGoogle]))
    xsl.transform(xmlDoc)
  end

end
