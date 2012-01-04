require 'google_exporter'
require 'test/unit'
require 'nokogiri'

class TestGoogleExporter < Test::Unit::TestCase
  def test_connect
    assert_nothing_raised do
      xmlSchedule = Nokogiri::XML(File.open('test/asset/xmlSchedule.xml'))   
      exporter = GoogleExporter.new(xmlSchedule)
      
      exporter.auth      
    end
  end
end