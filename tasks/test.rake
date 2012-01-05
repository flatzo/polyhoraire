require 'rake/testtask'

Rake::TestTask.new(:test) do |i|
  i.libs << File.expand_path(File.dirname(__FILE__) + "/../src/")
  i.test_files = FileList['test/poly/test_*.rb','test/test_*.rb']
end

namespace :test do
  Rake::TestTask.new(:offline) do |i|
    i.libs << File.expand_path(File.dirname(__FILE__) + "/../src/")
    i.test_files = FileList['test/poly/test_period.rb']
  end
end
