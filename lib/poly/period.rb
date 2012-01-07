require 'poly'

require 'nokogiri'

class Poly::Period
  include Poly
  attr_reader :from, :to,:week, :weekDay, :group, :location, :isLab 
  
  def initialize(from,to,week,weekDay,group,location,isLab)
    @from = from
    @to = to
    @week = week
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
  
  def dates(trimester,week,day)
    return @trimester.week[week][day]
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
    week     = extractWeek(moment.attribute('semaine').text)
    weekDay  = moment.attribute('jour').text.to_i
    group    = node.xpath("groupe").text
    location = node.xpath("local").text
    isLab    = node.attribute("type").text == "lab"
    
    self.new(from,to,week,weekDay,group,location,isLab)
  end
  
  def self.extractWeek(string)
    case string
    when 'B1'
      return 1
    when 'B2'
      return 2
    else
      return 0
    end
  end
end
