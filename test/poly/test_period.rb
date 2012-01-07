require 'poly/period'
require 'test/unit'
require 'nokogiri'

class TestPeriod < Test::Unit::TestCase
  def test_from_nokogiri
    assert_nothing_raised do
      xml = Nokogiri::XML(File.read("test/asset/schedule.xml"))
      
      p = Poly::Period.from_nokogiri(xml,"INF3990")[0]
      
      
      assert_equal('8:30' ,p.from)    
      assert_equal('10:30',p.to)
      assert_equal(2    ,p.weekDay)
      assert_equal('01'    ,p.group)
      assert_equal('M-1020',p.location)
      assert_equal(false    ,p.isLab)
    end
  end
end
