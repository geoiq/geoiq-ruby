class Geoiq
  class Search
    attr_reader :auth
    def initialize(auth, options={})
      @auth = auth
    end

    #format json/atom/kml
    def search(query, options={}, format='json')
      params = {:query => query}.merge(options)
      response = request(:get, "/search.#{format}", {:query => params })
      if format == 'json'
        return results = JSON.parse(response.body)
      else
        return response.body
      end
    end

    protected

    def request(method,  path, options = {})
      response = HTTParty.send(method, "#{auth.url}#{path}", :query => options[:query], :body => options[:body], :headers => {"Accept" => "application/xml", "Content-Type" => "application/xml; charset=utf-8", "Authorization" => "Basic #{auth.basic_auth}"}.update(options[:headers] || {}), :format => :plain)
    end

  end
end