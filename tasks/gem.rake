require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
    s.name       = "polyhoraire"
    s.bindir     = "bin"
    s.executable = "polyhoraire"
    s.version    = "1.0.1"
    s.author     = "Charles Briere"
    s.email      = "charles.briere@polymtl.ca"
    s.homepage   = "https://github.com/flatzo/polyhoraire"
    s.platform   = Gem::Platform::RUBY
    s.summary    = "Retrieve schedule from Polymtl and exports it"
    s.description= "Retrieve schedule from Polytechnique de Montreal and exports it to different formats(only google calendar is suported at this time)"
    s.files      = FileList["{bin,docs,lib,test}/**/*"].exclude("rdoc").to_a
    s.require_path      = "lib"
    s.extra_rdoc_files  = ['Readme.rdoc']
    
    s.add_dependency('nokogiri')
    s.add_dependency('tzinfo')
    s.add_dependency('google-api-client')
end

Gem::PackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end