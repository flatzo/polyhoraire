require 'singleton'
require './poly/auth'
require './poly/schedule'

class Ui
  include Singleton
  
  def initialize  
    @poly = Poly::Auth.new 
  end
  
  def run
    # Connect to poly
    begin
      connectPoly
      puts "Erreur : " + @poly.error[:message] unless @poly.connected?
    end until @poly.connected?
    
    schedule = Poly::Schedule.new(trimester,@poly.postParams)
    
  end
  
  
  
  private 
  def connectPoly 
    puts "Nom d'utilisateur : "
    user = gets.chomp
  
    puts "Mot de passe : "
    password = gets.chomp

    puts "Date de naissance : "
    bday = gets.chomp
  
    @poly.connect(user,password,bday) 
  end
end