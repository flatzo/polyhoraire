require 'rubygems'
require 'google/api_client'
require 'nokogiri'
require 'yaml'
require 'tzinfo'

class GoogleExporter
  
  def initialize
    auth
    @tz = TZInfo::Timezone.get('America/Montreal')
    @sentEvents = Array.new
  end

  def send(schedule,toCalID)
    @sentEvents = Array.new
    @sentCalendarID = toCalID
    
    schedule.courses.each do |course|
      course.periods.each do |period|
        
        courseBeginsOn = schedule.trimester.starts + period.weekDay - 1
        courseBeginsOn += 7 if period.week == 2
        event = {
          'summary' => course.acronym + '(' + period.group + ') ' + (period.isLab ? '[Lab]' : '') ,
          'location' => period.location,
          'timeZone' => 'America/Montreal',
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

        result = @client.execute(:api_method => @service.events.insert,
                        :parameters => {'calendarId' => toCalID},
                        :body_object => event,
                        :headers => {'Content-Type' => 'application/json'})
        @sentEvents.push(result)
      end
    end
  end
  
  def deleteEvent(eventID,calendarID)
    result = @client.execute(:api_method => @service.events.delete,
                            :parameters => {'calendarId' => calendarID, 'eventId' => eventID})
  end
  
  def deleteSentEvents
    @sentEvents.each do |event|
      deleteEvent(event.data.id,@sentCalendarID)
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
    date = DateTime.parse(date.to_s + ' ' + time)
    date = @tz.local_to_utc(date)
    date.strftime('%FT%TZ')
  end
  
  def rDates(trimester,period)
    str = ''
    trimester.getDates(period).each do |date|
      date = DateTime.parse(date.to_s + ' ' + period.from)
      date = @tz.local_to_utc(date)
      str += date.strftime('%Y%m%dT%H%M%SZ,')
    end
    str.chomp(',')
  end
  
  def to_calendar(xmlDoc)
    xsl = Nokogiri::XSLT(File.read(Poly::XSLDocs[:exportGoogle]))
    xsl.transform(xmlDoc)
  end

end
