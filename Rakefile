require 'rubygems'
require 'rake'
require 'lib/shadow/rake_task_redefine_task'

DIR = File.dirname(__FILE__)

begin
  require 'rake/clean'
  gem 'echoe', '>= 1.2'
  require 'echoe'
  require 'fileutils'
  include FileUtils

  CLEAN.include ['**/.*.sw?', '*.gem', '.config']  
  VERS = `cat CHANGELOG`[/^([\d\.]+)\. /, 1]
  
  echoe = Echoe.new("shadow", VERS) do |p|
    p.author = "Evan Weaver" 
    p.rubyforge_name = "fauna"
    p.name = "shadow"
    p.description = "A zero-configuration RESTful ActiveRecord server."
    p.changes = `cat CHANGELOG`[/^([\d\.]+\. .*)/, 1]
    p.email = "evan at cloudbur dot st"
    p.summary = p.description
    p.url = "http://blog.evanweaver.com/pages/code#shadow"
    p.need_tar = false
    p.need_tar_gz = true
    p.test_globs = ["*_test.rb"]
    p.extra_deps = ["activerecord", "mongrel"]
    p.clean_globs = CLEAN  
  end
            
rescue LoadError => boom
  puts "You are missing a dependency required for meta-operations on this gem."
  puts "#{boom.to_s.capitalize}."
  
  desc 'Run tests.'
  task :default => :test
end

desc 'Run tests.'
Rake::Task.redefine_task("test") do
  system "ruby -Ibin:lib:test test/integration/test_shadow.rb #{ENV['METHOD'] ? "--name=#{ENV['METHOD']}" : ""}"
end
