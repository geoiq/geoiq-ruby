module Geoiq
  class Mapject
    
    include HTTParty

    # base_uri 'http://api-sandbox.geoiq.com'
    # base_uri 'http://geoiq.local'
    # USERNAME = "admin"
    # PASSWORD = "password"

    base_uri 'http://api-sandbox.geoiq.com'
    USERNAME = "admin"
    PASSWORD = "password"
    # USERNAME = "acme"
    # PASSWORD = "1!Acm3!1"
    
    attr_accessor :base_uri

    # def initialize(map)
    #   
    # end
    
    public
    # Create a new instance by sending the standard attributes across.
    def create(options)
      request = send_post("#{object_path}.json", {:query => 
        self.class.attributes.inject({}) {|attrs, key| attrs[key] = self.send(key); attrs}.merge(options)
        })
      # raise request.inspect.to_s
      respond_to_status(request)
      self.geoiq_id = request.parsed_response['id'].to_i
    end

    def self.load(new_id = nil)
      model = self.new
      model.load(new_id)
      model
    end
    
    def load(new_id = nil)
      self.geoiq_id = new_id unless new_id.nil?
      request = send_get("#{object_path}/#{geoiq_id}.json")
      self.class.attributes.each do |a|
        self.send("#{a}=", request.parsed_response[a])
      end
      respond_to_status(request)
      self.geoiq_id.to_i
    end
      
    def save(options = {})
      options = self.class.attributes.inject({}) {|attrs, key| attrs[key] = self.send(key); attrs}.merge(options)
      if self.geoiq_id.nil?
        request = send_post("#{self.object_path}.json", {:query => options})
        if request["status"].to_i == 201 && self.geoiq_id.nil?
          self.geoiq_id = request["location"].match(/(\d+)\.json/)[1].to_i
        end
      else
        request = send_put("#{self.object_path}/#{self.geoiq_id}.json", {:query => options})
      end      
      respond_to_status(request)
      self.geoiq_id.to_i
    end  
  
    def delete(options = {})
      request = send_delete("#{object_path}/#{self.geoiq_id}.json")
      respond_to_status(request)
    end
      
    protected
    # REST methods
    def send_get(url, options = {})
      self.class.get(url, options.merge({:basic_auth => {:username => USERNAME, :password => PASSWORD}}))
    end
  
    def send_post(url, options = {})
      self.class.post(url, options.merge({:basic_auth => {:username => USERNAME, :password => PASSWORD}}))
    end

    def send_put(url, options = {})
      self.class.put(url, options.merge({:basic_auth => {:username => USERNAME, :password => PASSWORD}}))
    end

    def send_delete(url, options = {})
      self.class.delete(url, options.merge({:basic_auth => {:username => USERNAME, :password => PASSWORD}}))
    end
    
    def respond_to_status(request)
      # raise request.inspect.to_s unless [200,201].include?(request.headers['status'].to_i)
      raise GeoApiException unless [200,201].include?(request.headers['status'].to_i)
    end
  end
end

class GeoApiException < Exception;end;