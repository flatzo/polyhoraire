require 'google_exporter'
require 'poly/schedule'
require 'poly/auth'
require 'test/unit'
require 'nokogiri'

class TestGoogleExporter < Test::Unit::TestCase
  def setup
    @exporter = GoogleExporter.new
    
    auth = Poly::Auth.new
      
    @config = YAML.load_file("conf/test_poly.yaml")
    user      = @config['credentials']['user']
    password  = @config['credentials']['password']
    bday      = @config['credentials']['bday']
    
    auth.connect(user,password,bday)
    
    @schedule = Poly::Schedule.new(auth,20121)
  end
  
  def test_send
    @exporter.send(@schedule,'hg9a7o16bm6dj0tmuo481499mc@group.calendar.google.com')
  end
end