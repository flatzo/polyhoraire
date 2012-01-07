require 'rubygems'
require 'google/api_client'
require 'nokogiri'
require 'yaml'

class GoogleExporter

  def send(schedule)
    schedule.courses.each do |course|
      course.each do |period|
        
        event = {
          'summary' => course.acronym + '(' + period.group + ') ' + period.isLab ? '[Lab]' : '' ,
          'location' => period.location,
          'start' => {
            'dateTime' => dateTime(schedule.trimester.start),
            'timeZone' => 'America/Montreal'
          },
          'end' => {
            'dateTime' => dateTime(schedule.trimester.end),
            'timeZone' => 'America/Montreal'
          },
          'attendees' => [
            {
              'email' => 'attendeeEmail'
            },
            #...
          ]
        }
      end
    end
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
    oauth_yaml = YAML.load_file('conf/google-api.yaml')
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
  
  def dateTime(date, time)
    DateTime.parse(date + ' ' + time).strftime('yyyy-mm-ddTHH:MM:ss')
  end
  
  def to_calendar(xmlDoc)
    xsl = Nokogiri::XSLT(File.read(Poly::XSLDocs[:exportGoogle]))
    xsl.transform(xmlDoc)
  end

end
