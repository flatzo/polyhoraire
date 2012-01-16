require 'rubygems'
require 'google/api_client'
require 'nokogiri'
require 'yaml'
require 'tzinfo'
require 'data_mapper'

require 'polyhoraire'


# Set up our token store
DataMapper.setup(:default, 'sqlite::memory:')
class TokenPair
  include DataMapper::Resource

  property :id, Serial
  property :refresh_token, String, :length => 255
  property :access_token, String, :length => 255
  property :expires_in, Integer
  property :issued_at, Integer


  def update_token!(object)
    self.refresh_token = object.refresh_token
    self.access_token = object.access_token
    self.expires_in = object.expires_in
    self.issued_at = object.issued_at
  end

  def to_hash
    return {
      :refresh_token => refresh_token,
      :access_token => access_token,
      :expires_in => expires_in,
      :issued_at => Time.at(issued_at)
    }
  end
end
TokenPair.auto_migrate!


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
  def authWeb(code,tokenID,callBackURI)
    oauth_yaml = YAML.load_file(Poly::userConfDir + '/google-api.yaml')
    
    @client = Google::APIClient.new
    @client.authorization.client_id = oauth_yaml["client_id"]
    @client.authorization.client_secret = oauth_yaml["client_secret"]
    @client.authorization.scope = oauth_yaml["scope"]
    @client.authorization.redirect_uri = callBackURI
    @client.authorization.code = code if code
    
    if tokenID
      # Load the access token here if it's available
      token_pair = TokenPair.get(tokenID)
      @client.authorization.update_token!(token_pair.to_hash)
    end
    
    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end
    
    @service = @client.discovered_api('calendar', 'v3')
    
    return @client.authorization.access_token
  end
  
  # Returns the session token
  def authWebCallback(tokenID)
    @client.authorization.fetch_access_token!
    # Persist the token here
    token_pair = if tokenID
      TokenPair.get(tokenID)
    else
      TokenPair.new
    end
    TokenPair.auto_migrate!
    token_pair.update_token!(@client.authorization)
    token_pair.save
    
    return token_pair.id
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
