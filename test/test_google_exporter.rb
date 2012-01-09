require 'google_exporter'
require 'polyhoraire/schedule'
require 'polyhoraire/auth'
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
    @exporter.send(@schedule,'ekd38fnk731clljnj56svvvdgk@group.calendar.google.com')
    puts "Verify manually that every events have been created and press any key"
    STDIN.gets.chomp
    @exporter.deleteSentEvents()
  end
end