require 'polyhoraire'
require 'yaml'

class Poly::Trimester
  attr_reader :week, :starts
  
  DAY_RANGE = (1..5)
  WEEK_RANGE = (1..2)
  
  # Create from a YAML file wich is situated in 'conf/trimesters.yaml'
  def self.fromYAML(trimesterID)
    config = YAML.load_file(Poly::userConfDir + "/trimesters.yaml")
    raise ArgumentError, "Invalid trimester : " + trimesterID.to_s unless config.include?(trimesterID)
    selected = config[trimesterID]
    
    
    starts      = selected['starts']
    schoolBreak = selected['schoolBreak']
    ends        = selected['ends']
    holidays    = selected['holidays']
    exceptions  = selected['exceptions']
    
    return self.new(starts, schoolBreak, ends, holidays, exceptions)
  end
  
  # period : Period object for wich you want every dates it occurs
  # Returns the list of dates for the course period
  def getDates(period)
    if period.week == 0
      dates = @week[1][period.weekDay] + @week[2][period.weekDay] 
      return dates.sort
    end
    return @week[period.week][period.weekDay].sort
  end
  
  private
  
  def initialize(starts, schoolBreak, ends, holidays, exceptions)
    @starts = starts
    @schoolBreak = schoolBreak
    @ends = ends
    @holidays = holidays
    @exceptions = exceptions 
    
    @week = Hash.new
    generateDates
  end
  
  def generateDates
    WEEK_RANGE.each do |w|
      @week[w] = Hash.new
      DAY_RANGE.each do |d|
        @week[w][d] = datesFor(d,w)
      end
    end
  end
    
  def datesFor(day,week)
    
    raise ArgumentError, "Day not in accepted range" unless DAY_RANGE.cover?(day)
    raise ArgumentError, "Week not in accepted range" unless WEEK_RANGE.cover?(week)
    starts = @starts + day-1 + 7*(week-1)
    
    dates = Array.new
    dates = datesUntil(starts,@schoolBreak)
    dates += datesUntil(dates.last + 21,@ends)
    dates += exceptionDates(day,week)
    
    return dates
  end
  
  def exceptionDates(day,week)
    dates = Array.new
    @exceptions.each do |date, changedTo|
      if changedTo['week'] == 'b' + week.to_s and changedTo['day'] == day
        dates.push(date)
      end
    end
    
    return dates
  end
  
  def datesUntil(from, to)
    dates = Array.new
    
    iDate = from
    while (iDate <=> to) == -1
      dates.push(iDate) unless dayChanged?(iDate)
      iDate += 14
    end
    return dates
  end
  
  def dayChanged?(date)
    @exceptions.has_key?(date) or @holidays.include?(date)
  end
    
end