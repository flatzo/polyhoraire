require 'singleton'
require 'poly/auth'
require 'poly/schedule'
require 'google_exporter.rb'

class CLI
  include Singleton
  
  def initialize  
    @auth = Poly::Auth.new 
  end
  
  def run
    # Connect to poly
    begin
      connectPoly
    rescue
      puts "Erreur : " + @auth.error[:message]
      retry
    end
    
    schedule = Poly::Schedule.new(@auth.trimesters,@auth.postParams)
    
    
    begin
      trimester = selectTrimester
      schedule.get(trimester)
    rescue
      "Erreur : Trimester invalide"
      retry
    end 
    
    File.open('fudge.xml','w') {|f| schedule.to_xml_doc.write_xml_to f}
    puts schedule.to_xml
    
    
    google = GoogleExporter.new(schedule.to_xml_doc)
    
    
    
    
  end
  
  
  
  private 
  def connectPoly 
    puts "Nom d'utilisateur : "
    user = gets.chomp
  
    puts "Mot de passe : "
    password = gets.chomp

    puts "Date de naissance : "
    bday = gets.chomp
  
    @auth.connect(user,password,bday) 
  end
  
  def selectTrimester
    puts "----------------------"
    puts " Liste des trimestres "
    puts "----------------------"
    showTrimesters
    puts ""
    puts "Selectionner le trimester :"
    trimester = gets.chomp
    return trimester
  end
  
  def showTrimesters
    @auth.trimesters.each do |id,label|
      puts id + " : " + label
    end
  end
  
  
end