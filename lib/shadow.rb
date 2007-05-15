
require 'rubygems'
require 'mongrel'
require 'active_record'
require 'sync'

class Shadow < Mongrel::HttpHandler
  attr_reader :pid

  def initialize(config, environment, name, address = '0.0.0.0', port = '2001', sleep = nil)
    ActiveRecord::Base.establish_connection(YAML.load_file(config)[environment.to_s])
    ActiveRecord::Base.allow_concurrency = false    
    @sleep = sleep
    @sync = Sync.new
    @pid = serve(self, name, address, port)
  end
  
  def process(request, response)
    sleep(rand * @sleep) if @sleep
    table, id = request.params["PATH_INFO"].split("/")

    obj, code = nil, 200
    @sync.synchronize(:EX) do # fuckin AR
      begin
        obj = find(table, id)
        case request.params["REQUEST_METHOD"]
          when "PUT", "POST"
            obj.update_attributes(YAML.load(request.body.read))
            obj.save!
          when "DELETE"
            obj.destroy
        end
        obj = obj.attributes
      rescue Object => e
        obj, code = e.to_s, 400
      end
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
  
  ### configure mongrel ###
      
  def serve(me, name, address, port)
    fork do
      Mongrel::Configurator.new :host => address, :pid_file => "/tmp/shadow.#{name}.pid" do
        listener :port => port do
          puts "** Serving at #{address}:#{port}/#{name}/ (pid #{Process.pid})"
          uri "/#{name}/", :handler => me
          setup_signals or run and write_pid_file and join
        end
      end
    end
  end

  ### debugging ###
  
  def self.d
    require 'ruby-debug'; Debugger.start; debugger
  end  
  
end
