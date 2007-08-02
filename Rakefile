
require 'rubygems'

DIR = File.dirname(__FILE__)

begin
  gem 'echoe', '>= 1.2'
  require 'echoe'

  VERS = `cat CHANGELOG`[/^v([\d\.]+)\. /, 1]
  
  echoe = Echoe.new("shadow", VERS) do |p|  
    p.author = "Evan Weaver" 
    p.rubyforge_name = "fauna"
    p.name = "shadow"
    p.description = "A zero-configuration RESTful ActiveRecord server."
    p.changes = `cat CHANGELOG`[/^v([\d\.]+\. .*)/, 1]
    p.summary = p.description

    p.url = "http://blog.evanweaver.com/pages/code#shadow"
    p.docs_host = "blog.evanweaver.com:~/www/snax/public/files/doc/"

    p.extra_deps = ["activerecord", "mongrel"]
    p.need_tar = false
    p.need_tar_gz = true

    p.rdoc_pattern = /\.\/bin|\.\/lib\/shadow\.rb|README|CHANGELOG|LICENSE/    
  end
            
end
