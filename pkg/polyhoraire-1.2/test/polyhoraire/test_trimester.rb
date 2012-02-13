require 'polyhoraire/trimester'
require 'polyhoraire/period'

require 'test/unit'
require 'yaml'

class TestTrimester < Test::Unit::TestCase

  def setup
    @trimester = Poly::Trimester.fromYAML(20121)
  end
  def test_week
    assert_nothing_raised do
      
      #puts trimester.datesFor(4,2)
      fridayB1 = [
        Date.new(2012,01,13),
        Date.new(2012,01,27),
        Date.new(2012,02,10),
        Date.new(2012,02,24),
        Date.new(2012,03,16),
        Date.new(2012,03,30),
        Date.new(2012,04,17)
        ]  
      assert_equal(fridayB1,@trimester.week[1][5])
      
    end
  end
  
  def test_getDates
    xml = Nokogiri::XML(File.read("test/asset/schedule.xml"))
      
    period = Poly::Period.new('8:30','9:30',0,4,'01','Endroit',true)
    dates  = [
      Date.new(2012,01,12),
      Date.new(2012,01,19),
      Date.new(2012,01,26),
      Date.new(2012,02,2),
      Date.new(2012,02,9),
      Date.new(2012,02,16),
      Date.new(2012,02,23),
      Date.new(2012,03,1),
      Date.new(2012,03,15),
      Date.new(2012,03,22),
      Date.new(2012,03,29),
      Date.new(2012,04,5),
      Date.new(2012,04,12)
    ]
    assert_equal(dates,@trimester.getDates(period))

    period = Poly::Period.new('8:30','9:30',2,4,'01','Endroit',true)
    dates  = [
      Date.new(2012,01,19),
      Date.new(2012,02,2),
      Date.new(2012,02,16),
      Date.new(2012,03,1),
      Date.new(2012,03,22),
      Date.new(2012,04,5)
    ]
    assert_equal(dates,@trimester.getDates(period))
    
          
    period = Poly::Period.new('8:30','9:30',1,4,'01','Endroit',true)
    dates  = [
      Date.new(2012,01,12),
      Date.new(2012,01,26),
      Date.new(2012,02,9),
      Date.new(2012,02,23),
      Date.new(2012,03,15),
      Date.new(2012,03,29),
      Date.new(2012,04,12)
    ]
    assert_equal(dates,@trimester.getDates(period))
  end
end
