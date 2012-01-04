desc 'Run tests for this app'
task :test do
  $: << File.expand_path(File.dirname(__FILE__) + "/../test")
  $: << File.expand_path(File.dirname(__FILE__) + "/../src")
  
  $config = YAML.load_file("conf/test_poly.yaml")
  
  puts "Initialisation des tests"
  require 'ts_all'
end