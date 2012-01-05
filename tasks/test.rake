desc 'Run tests for this app'

task :test => ['test:online', 'test:offline']

namespace :test do
  task :init do
    $: << File.expand_path(File.dirname(__FILE__) + "/../test")
    $: << File.expand_path(File.dirname(__FILE__) + "/../src")
    
    $config = YAML.load_file("conf/test_poly.yaml")
    
    puts "Initialisation des tests"
  end
  
  task :online => ['init'] do
    require 'ts_online'
  end
  
  task :offline => ['init'] do 
    require 'ts_offline'
  end
end