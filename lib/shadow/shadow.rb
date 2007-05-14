
require 'rubygems'
require 'mongrel'
require 'active_record'

class Shadow < Mongrel::HttpHandler
   def initialize(config, environment, name)
     @config = YAML.load_file(config)[environment.to_s]
     @name = name
   end

   def process(request, response)      response.start(200) do |head, out|         head["Content-Type"] = "text/html"         out.write "Hello"      end   end   def connection      @connection ||= establish_connection   end   def establish_connection      config =       ActiveRecord::Base.allow_concurrency = true      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection   endend

