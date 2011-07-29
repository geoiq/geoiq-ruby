module Geoiq

  class Client
    include HTTParty
    default_timeout 240
   
     def initialize(url, username=nil, password=nil)
      @username = username
      @url = url
      self.class.base_uri(url)
      @auth = {:username => username, :password => password}
    end


  end

end

