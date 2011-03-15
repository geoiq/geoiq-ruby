module Geoiq

  class Client
    include HTTParty
    #base_uri "geocommons.com"
     def initialize(url="localhost.local", username=nil, password=nil)
      @username = username
      @url = url
      self.class.base_uri(url)
      @auth = {:username => username, :password => password}
    end


  end

end

