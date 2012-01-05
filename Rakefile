require 'yaml'
require 'fileutils'

Dir.glob('tasks/*.rake').each { |r| import r }

task :clean do
  FileUtils.rm Dir.glob('conf/*.yaml')
end
