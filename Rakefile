require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "geoiq"
  s.version = "0.0.2"
  s.author = "Tim Waters"
  s.email = "tim.waters@fortiusone.com"
  s.homepage = "http://github.com/fortiusone/geoiq_gem"
  s.platform = Gem::Platform::RUBY
  s.summary = "API Wrapper around Geocommons website and the GeoIQ applications"
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.add_dependency("httparty", ">= 0.7.4")
  s.add_dependency("json", ">= 1.1.9")
  s.add_development_dependency('shoulda')
  s.add_development_dependency('fakeweb')
  s.add_development_dependency('geo_ruby')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Default task: builds gem"
task :default => [ :gem, :doc ]

desc 'Install the gem'
namespace 'gem' do
  task :install do
    path = "pkg/#{spec.name}-#{spec.version}.gem"
    exec "gem install #{path}"
  end
end
