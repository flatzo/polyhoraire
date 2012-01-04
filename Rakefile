require 'yaml'
require 'fileutils'

# Defaults for namespaces
task :setup => 'setup:all'



task :test do
  $: << File.expand_path(File.dirname(__FILE__) + "/test")
  $: << File.expand_path(File.dirname(__FILE__) + "/src")
  
  $config = YAML.load_file("conf/test_poly.yaml")
  
  puts "Initialisation des tests"
  require 'ts_all'
end

namespace :setup do
  
  task :all do
    Rake::Task['setup:poly_auth'].invoke
    Rake::Task['setup:google_api'].invoke
  end
  
  desc 'Configure your acces to poly for unit-test'
  task :poly_auth do
    puts " ------------------------------ "
    puts " Identifiants de connexion au   "
    puts "       dossier etudiant         "
    puts " ------------------------------ "
    
    credentials = Hash.new
    puts "Utilisateur : "
    credentials['user']      = STDIN.gets.chomp
    puts "Mot de passe : "
    credentials['password']  = STDIN.gets.chomp
    puts "Date d'anniversaire : "
    credentials['bday']      = STDIN.gets.chomp   
    yaml = Hash.new
    
   yaml['credentials'] = credentials
    
    File.open('conf/test_poly.yaml', 'w') do |out|
      YAML.dump(yaml,out)
    end
  end
  
  desc 'Configure your access to google-api'
  task :google_api do
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

=begin
    puts " ------------------------------ "
    puts " Using the following command   "
    puts " to prepare configuration file  "
    puts " ------------------------------ "
    puts command
=end

    system(command)
    FileUtils.mv(Dir.home + '/.google-api.yaml', 'conf/google-api.yaml')
    puts "Creation du fichier de configuration dans :"
    puts " => conf/google-api.yaml"
    
  end
end

task :clean do
  FileUtils.rm Dir.glob('conf/*.yaml')
end
