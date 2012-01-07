require 'poly/auth'
require 'poly/schedule'

require 'test/unit'
require 'nokogiri'
require 'yaml'

class TestSchedule < Test::Unit::TestCase
  def setup
    @config = YAML.load_file("conf/test_poly.yaml")
  end
  
  def test_get
    assert_nothing_raised do
      doc = Nokogiri::XML(File.read("test/asset/schedule.xml"))
      
      auth = Poly::Auth.new
      
      user      = @config['credentials']['user']
      password  = @config['credentials']['password']
      bday      = @config['credentials']['bday']
      
      auth.connect(user,password,bday)
      
      schedule = Poly::Schedule.new(auth,20121)
      
      assert_equal(doc.to_s ,schedule.to_xml)    
    end
  end
end
