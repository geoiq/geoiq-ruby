class Geoiq
  class BaseModel
    attr_reader :auth, :json

    def initialize(auth, options={})
      @auth = auth
    end


    class << self
      def api_methods(methods)
        class_eval <<-END
        def api_methods
          #{methods.inspect}
        end
        END
      end

      def crud
        %w(find create update delete)
      end


    end

    protected

    # parse in json and create a new model
    def self.parse(response, auth, options=nil)
      model = self.new(auth, options)
      json = JSON.parse(response.body)
      model.json = json  #stuff the json in there for good measure
      model.attributes.each do |a|
        model.send("#{a}=", json[a])
      end

      model

    end

    def request(method,  path, options = {})

      response = HTTParty.send(method, "#{auth.url}#{path}", :query => options[:query], :body => options[:body], :headers => {"Accept" => "application/xml", "Content-Type" => "application/xml; charset=utf-8", "Authorization" => "Basic #{auth.basic_auth}"}.update(options[:headers] || {}), :format => :plain)
      case response.code
      when 503
        p 503 #TODO, raise errors
      else
        response
      end
    end


    def requires_geoiq_id
      raise NoGeoiqIDFoundError unless self.geoiq_id
    end
    
  end
end

