task :test do
  $: << File.expand_path(File.dirname(__FILE__) + "/test")
  $: << File.expand_path(File.dirname(__FILE__) + "/src")
  
  require 'yaml'

  $config = YAML.load_file("test/config.yaml")
  
  puts "Initialisation des tests"
  require 'ts_all'
end