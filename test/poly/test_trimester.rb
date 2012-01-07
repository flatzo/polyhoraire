require 'poly/trimester'

require 'test/unit'
require 'yaml'

class TestTrimester < Test::Unit::TestCase

  def test_week
    assert_nothing_raised do
      trimester = Poly::Trimester.fromYAML(20121)
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
      assert_equal(fridayB1,trimester.week[1][5])
      
    end
  end
end
