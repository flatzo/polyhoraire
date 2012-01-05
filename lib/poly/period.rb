require 'poly'

require 'nokogiri'

class Poly::Period
  include Poly
  attr_reader :from, :to, :weekDay, :group, :location, :isLab 
  
  def initialize(from,to,weekDay,group,location,isLab)
    @from = from
    @to = to
    @weekDay = weekDay
    @group = group
    @location = location
    @isLab = isLab
  end
   
  def self.from_nokogiri(doc, acronym)
    nodeSet = doc.xpath("//evenement[sigle = '" + acronym + "']")
    if nodeSet.nil? || nodeSet.empty?
      raise ArgumentError
    else
      periods = Array.new
      nodeSet.each do |node|
        periods.push self.parse_node(node)
      end
    
      return periods
    end
    
   
  end
  
  def to_s
    puts "---"
    puts "From : " + @from + " To : " + @to + " On day : " + @weekDay
    puts "---"
  end
  
  private
  
  def self.parse_node(node)
    moment = node.xpath("moment")
    
    from     = moment.attribute('debut').text
    to       = moment.attribute('fin').text
    weekDay  = moment.attribute('jour').text
    group    = node.xpath("groupe").text
    location = node.xpath("local").text
    isLab    = node.attribute("type").text == "lab"
    
    self.new(from,to,weekDay,group,location,isLab)
  end
end
