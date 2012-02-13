require 'rubygems'
require 'google/api_client'
require 'nokogiri'
require 'yaml'
require 'tzinfo'

require 'polyhoraire'


# Set up our token store
class TokenPair

  def initialize(hash)
    if hash != nil
      @access_token = hash[:access_token]
      @expires_in   = hash[:expires_in]
      @issued_at    = hash[:issued_at]
      @refresh_token= hash[:refresh_token]
    end
  end

  def update_token!(object)
    @refresh_token  = object.refresh_token
    @access_token   = object.access_token
    @expires_in     = object.expires_in
    @issued_at      = object.issued_at
  end
  
  def set?
    @refresh_token != nil
  end

  def to_hash
    return {
      :refresh_token  => @refresh_token,
      :access_token   => @access_token,
      :expires_in     => @expires_in,
      :issued_at      => Time.at(@issued_at)
    }
  end
end

# Class that make it possible to export a Schedule object to a google calendar
# Before any operation, you must authenticate the user.
class GoogleExporter
  attr_reader :sentEvents
  
  def initialize
    @tz = TZInfo::Timezone.get('America/Montreal')
    @sentEvents = Array.new
  end
  
  def self.from_client(client)
    exporter = self.new
    exporter.client = client
    exporter.service = client.service
  end
  
  
  # Send a schedule object to a specified calendarID
  def send(schedule,toCalID)
    @sentEvents = Array.new
    events = Array.new
    @sentCalendarID = toCalID
    
    schedule.courses.each do |course|
      course.periods.each do |period|
        
        courseBeginsOn = schedule.trimester.starts + period.weekDay - 1
        courseBeginsOn += 7 if period.week == 2
        event = {
          'summary' => course.acronym + '(' + period.group + ') ' + (period.isLab ? '[Lab]' : '') ,
          'description' => course.description ,
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

        result = @client.execute!(:api_method => @service.events.insert,
                        :parameters => {'calendarId' => toCalID},
                        :body_object => event,
                        :headers => {'Content-Type' => 'application/json'})
        @sentEvents.push(result)
        rEvent = {
          :id => result.data.id,
          :summary => result.data.summary,
          :htmlLink => result.data.htmlLink
        }
        events.push(rEvent)
      end
    end
    return events
  end
  
  # Create a calendar with the specified name and exports the schedule right after
  def createAndSend(calendarName,schedule) 
    calendar = {
      'summary' => calendarName,
      'timeZone' => 'America/Los_Angeles'
    }
    result = client.execute(:api_method => service.calendars.insert,
                            :body => JSON.dump(calendar),
                            :headers => {'Content-Type' => 'application/json'})
                            
    send(schedule,result.data.id)
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
 
  
  # return : hash[:calendarID => :calendarName]
  def calendarList
    list = Hash.new
    
    page_token = nil
    result = @client.execute(:api_method => @service.calendar_list.list)
    while true
      entries = result.data.items
      entries.each do |e|
        list[e.id] = e.summary
      end
      if !(page_token = result.data.next_page_token)
        break
      end
      result = @client.execute(:api_method => @service.calendar_list.list,
                              :parameters => {'pageToken' => page_token})
    end
    
    list
  end
  
  # Returns access token
  def authWeb(code,callBackURI,tokenPair = nil)
    oauth_yaml = YAML.load_file(Poly::userConfDir + '/google-api.yaml')
    
    @client = Google::APIClient.new
    @client.authorization.client_id = oauth_yaml["client_id"]
    @client.authorization.client_secret = oauth_yaml["client_secret"]
    @client.authorization.scope = oauth_yaml["scope"]
    @client.authorization.redirect_uri = callBackURI
    @client.authorization.code = code if code
    
    if tokenPair.set?
      @client.authorization.update_token!(tokenPair.to_hash)
    end
    
    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end
    
    @service = @client.discovered_api('calendar', 'v3')
    
    return @client.authorization.access_token
  end

  
  def authURI
    @client.authorization.authorization_uri.to_s
  end
  
  def auth_cli
    oauth_yaml = YAML.load_file(Poly::userConfDir + '/google-api.yaml')
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
  
  def newTokenPair 
    @client.authorization.fetch_access_token!
    token = TokenPair.new(nil)
    token.update_token!(@client.authorization)
    return token
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
