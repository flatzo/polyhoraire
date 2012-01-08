require 'rubygems'
require 'google/api_client'
require 'nokogiri'
require 'yaml'

class GoogleExporter
  
  def initialize
    auth
  end

  def send(schedule,toCalID)
    schedule.courses.each do |course|
      course.periods.each do |period|
        
        courseBeginsOn = schedule.trimester.starts + period.weekDay - 1
        puts dateTime(courseBeginsOn, period.to)
        event = {
          'summary' => course.acronym + '(' + period.group + ') ' + (period.isLab ? '[Lab]' : '') ,
          'location' => period.location,
          'start' => {
            'dateTime' => dateTime(courseBeginsOn, period.from),
            'timeZone' => 'America/Montreal'
          },
          'end' => {
            'dateTime' => dateTime(courseBeginsOn, period.to),
            'timeZone' => 'America/Montreal'
          },
          'recurrence' => [
              'RDATE;VALUE=DATE:' + rDates(schedule.trimester,period)
            ]
        }
=begin
event = {
  'summary' => 'Appointment',
  'location' => 'Somewhere',
  'start' => {
     'dateTime' => '2011-06-03T10:00:00.000-07:00',
     'timeZone' => 'America/Montreal'
  },
  'end' => {
     'dateTime' => '2011-06-03T10:25:00.000-07:00',
     'timeZone' => 'America/Montreal'
  },
  'recurrence' => [
    "RRULE:FREQ=DAILY;COUNT=5"
  ]
}
=end     
        result = @client.execute(:api_method => @service.events.insert,
                        :parameters => {'calendarId' => 'bmsj63rckceis8d0apkahs3r6c@group.calendar.google.com'},
                        :body_object => event,
                        :headers => {'Content-Type' => 'application/json'})
        puts result.data.id.to_s
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
    
    @service = client.discovered_api('calendar', 'v3')
    
    @client = client
  end

  def auth?

  end
  
  private 
  
  def dateTime(date, time)
    DateTime.parse(date.to_s + ' ' + time).strftime('%FT%T')
  end
  
  def rDates(trimester,period)
    str = ''
    trimester.getDates(period).each do |date|
      date = DateTime.parse(date.to_s + ' ' + period.from)
      str += date.strftime('%Y%m%dT%H%M%S,')
    end
    str.chomp(',')
  end
  
  def to_calendar(xmlDoc)
    xsl = Nokogiri::XSLT(File.read(Poly::XSLDocs[:exportGoogle]))
    xsl.transform(xmlDoc)
  end

end
