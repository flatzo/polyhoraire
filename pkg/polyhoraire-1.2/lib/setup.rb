#!/usr/bin/env ruby

#encoding : UTF-8

module Setup
  def self.google
    puts " ------------------------------ "
    puts " Google-API connection settings "
    puts "  => https://code.google.com/apis/console"
    puts " ------------------------------ "
    puts " 1. Client ID : "
    clientID = STDIN.gets.chomp
    puts " 2. Client secret : "
    clientSecret = STDIN.gets.chomp
    scope = "https://www.googleapis.com/auth/calendar"
    
    command = "google-api oauth-2-login --scope=" + scope + " --client-id=" + clientID + " --client-secret=" + clientSecret
    
    
    system(command)
    FileUtils.mv(Dir.home + '/.google-api.yaml', Poly::userConfDir + '/google-api.yaml')
    puts "Creation du fichier de configuration dans :"
    puts " => " + Poly::userConfDir + "/google-api.yaml"
  end
end
