# encoding: utf-8

require 'poly/course'
require 'test/unit'
require 'nokogiri'

class TestCourse < Test::Unit::TestCase
  
  def test_from_nokogiri
    assert_nothing_raised do
      xml = Nokogiri::XML(File.read("test/asset/schedule.xml"))
      
      course = Poly::Course.from_nokogiri(xml)[0]
      
      assert_equal('INF3005'                      ,course.acronym)
      assert_equal('COMMUNICATION ECRITE ET ORALE',course.name)
      assert_equal("Dominique Chassé"             ,course.professor)
      assert_equal('01'                           ,course.group)
      assert_equal(''                             ,course.labGroup)
      assert_equal('01'                           ,course.creditNbr)
      
      assert_equal(1,course.periods.size)
    end
  end
end
