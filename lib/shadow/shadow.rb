
require 'rubygems'
require 'mongrel'
require 'active_record'

class Shadow < Mongrel::HttpHandler
  attr_reader :pid

  def initialize(config, environment, name, address = '0.0.0.0', port = '2001')
    @config = YAML.load_file(config)[environment.to_s]
    @db = db
    @pid = serve(self, name, address, port)
  end
  
  def process(request, response)
    table, id = request.params["PATH_INFO"].split("/")
    begin
      obj, code = find(table, id), 200
      case request.params["REQUEST_METHOD"]
        when "PUT", "POST"
          Shadow.d
          obj.save! 
        when "DELETE"
          obj.destroy!
      end
      code = 200
    rescue Object => e
      obj, code = e, 400
    end
    response.start(code) do |head, out|
      head["Content-Type"] = "text/yaml"
      out.write obj.to_yaml
    end
  end
  
  def find(table, id)
      klass = Class.new(ActiveRecord::Base) { self.table_name = table }
      id ? klass.find(id) : klass.new
  end
  
  ### configure stuff ####
  
  def db
    ActiveRecord::Base.allow_concurrency = true
    ActiveRecord::Base.establish_connection(@config)
    ActiveRecord::Base.connection
  end
    
  def serve(me, name, address, port)
    fork do
      Mongrel::Configurator.new :host => address, :pid_file => "/tmp/shadow.#{name}.pid" do
        listener :port => port do
          puts "** Serving at #{address}:#{port}/#{name} (pid #{Process.pid})"
          uri "/#{name}/", :handler => me
          setup_signals or run and write_pid_file and join
        end
      end
    end
  end
  
  def self.d
    require 'ruby-debug'; Debugger.start; debugger
  end  
  
end
