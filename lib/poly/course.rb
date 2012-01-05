require 'poly'
require 'poly/period'
require 'nokogiri'

class Poly::Course
  @periodes = Hash.new
  attr_reader :acronym, :name, :professor, :group, :labGroup, :creditNbr, :periods
  attr_writer :acronym, :name, :professor, :group, :labGroup, :creditNbr
    
  def self.from_nokogiri(doc)
    courses = Array.new
    
    nodeSet = doc.xpath("//cour")
    nodeSet.each do |node|
      course = self.new
      
      course.acronym     = node.attribute("sigle").text
      course.name        = node.xpath("nom").text
      course.professor   = node.xpath("prof").text
      course.group       = node.xpath("groupeTheorie").text
      course.labGroup    = node.xpath("groupeLaboratoire").text
      course.creditNbr   = node.xpath("nombreCredits").text
      
      course.addPeriods(doc)
      
      courses.push(course)
    end
    return courses
  end
  
  def addPeriods (xml)
    @periods = Poly::Period.from_nokogiri(xml,@acronym) 
  end
  
  def description
    name + '\n' + 
    '\t\t - Professeur   : ' + professor + '\n' + 
    '\t\t - Groupe cours : ' + group + '\n' + 
    '\t\t - Groupe lab   : ' + labGroup
  end
end