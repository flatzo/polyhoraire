require 'rubygems'
require 'google/api_client'
require 'nokogiri'

class GoogleExporter
  OAUTH = {
    :key          => "",
    :secret       => "",
    :url          => "https://www.google.com/accounts/OAuthGetRequestToken"
  }
  
  def initialize(xmlDoc)
    @calendar = to_calendar(xmlDoc)
    puts @calendar.to_xml.to_s
  end

  ## Using GData utility library : http://code.google.com/apis/gdata/articles/gdata_on_rails.html
  def send
    
  end
  
  def selectCalendar(idUrl)
    
  end
  
  def listCalendars
    
  end

  def auth?

  end

  def webAuth
    @consumer=OAuth::Consumer.new( OAUTH[:key],OAUTH[:secret], {
    :site=> OATH[:url]
    })
    
    @request_token=@consumer.get_request_token
    session[:request_token]=@request_token
    redirect_to @request_token.authorize_url
  end

  def cliAuth(user,password)
    client = GData::Client::Calendar.new
    client.clientLogin(user,password)  
  end

  private 
  
  def to_calendar(xmlDoc)
    xsl = Nokogiri::XSLT(File.read(Poly::XSLDocs[:exportGoogle]))
    xsl.transform(xmlDoc)
  end

end
