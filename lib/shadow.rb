
require 'rubygems'
require 'mongrel'
require 'active_record'
require 'sync'

class Shadow < Mongrel::HttpHandler
  attr_reader :pid

  def initialize(config, environment, name, address = '0.0.0.0', port = '2001', sleep = nil)
    ActiveRecord::Base.establish_connection(YAML.load_file(config)[environment.to_s])
    ActiveRecord::Base.allow_concurrency = false # AR doesn't release connections fast enough
    @sleep = sleep
    @sync = Sync.new
    @pid = serve(self, name, address, port)
  end
  
  # Implement the <tt>mongrel</tt> event handler. Responds to all four HTTP methods.  
  def process(request, response)
    sleep(rand * @sleep) if @sleep
    table, id = request.params["PATH_INFO"].split("/")

    obj, code = nil, 200
    @sync.synchronize(:EX) do # sad
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
  
  # Finds and returns an ActiveRecord instance (returns a new record if <tt>id</tt> is nil). Dynamically instantiates an ActiveRecord parent class for each call. 
  def find(table, id)
    klass = Class.new(ActiveRecord::Base) { self.table_name = table }
    id ? klass.find(id) : klass.new
  end
    
  # Configure mongrel and start an instance of ourselves.      
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

  private
  
  def self.d
    require 'ruby-debug'; Debugger.start; debugger
  end  
  
end
