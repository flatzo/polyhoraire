require 'rake/testtask' 

Rake::TestTask.new(:test) do |i|
  i.test_files = FileList['**/test_*.rb']
end

namespace :test do
  Rake::TestTask.new(:offline) do |i|
    i.test_files = FileList['test/poly/test_period.rb']
  end
  
  
  task :poly => ['poly:all']
  namespace :poly do
    Rake::TestTask.new(:all) do |i|
      i.test_files = FileList['test/poly/test_*.rb']
    end
    
    Rake::TestTask.new(:course) do |i|
      i.test_files = FileList['test/poly/test_course.rb']
    end
    
    Rake::TestTask.new(:period) do |i|
      i.test_files = FileList['test/poly/test_period.rb']
    end
    
    Rake::TestTask.new(:schedule) do |i|
      i.test_files = FileList['test/poly/test_schedule.rb']
    end
    
    Rake::TestTask.new(:trimester) do |i|
      i.test_files = FileList['test/poly/test_trimester.rb']
    end
    
    
  end  
  
  
end
