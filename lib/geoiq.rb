module Geoiq
  class Mapject
    
    include HTTParty

    # base_uri 'http://api-sandbox.geoiq.com'
    base_uri 'http://geoiq.local'
    USERNAME = "admin"
    PASSWORD = "password"
    
    attr_accessor :base_uri

    # def initialize(map)
    #   
    # end

    # Create a new instance by sending the standard attributes across.
    def create(options)
      request = send_post("#{object_path}.json", {:query => 
        self.attributes.inject({}) {|attrs, key| attrs[key] = self.send(key)}.merge(options)
        })
      # raise request.inspect.to_s
      respond_to_status(request)
      self.geoiq_id = request.parsed_response['id']
    end
  
    def load(new_id = nil)
      self.geoiq_id = new_id unless new_id.nil?
      request = send_get("#{object_path}/#{geoiq_id}.json")
      self.class.attributes.each do |a|
        self.send("#{a}=", request[a])
      end
    end

    def update(options = {})
      request = send_put("#{object_path}/#{self.geoiq_id}.json", 
      {:query => 
        self.attributes.inject({}) {|attrs, key| attrs[key] = self.send(key)}.merge(options)
        })
      respond_to_status(request)
    end  
  
    def delete(options = {})
      request = send_delete("#{object_path}/#{self.geoiq_id}.json")
      respond_to_status(request)
    end
      
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