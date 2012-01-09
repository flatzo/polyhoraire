desc 'Run complet setup'
task :setup => 'setup:user'


namespace :setup do
  
  desc 'Configuration complete (developpeur)'
  task :developper => [:user,:poly_auth]
  desc 'Configuration minimale (utilisateur)'
  task :user => [:dependencies,:google_api]
  
  task :dependencies do
    system 'bundle install'
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
    
    File.open(Poly::userConfDir + '/test_poly.yaml', 'w') do |out|
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


    system(command)
    FileUtils.mv(Dir.home + '/.google-api.yaml', Poly::userConfDir + '/google-api.yaml')
    puts "Creation du fichier de configuration dans :"
    puts " => " + Poly::userConfDir + "/google-api.yaml"
    
  end
end