class Geoiq
  class Auth
    attr_accessor :url, :username, :password, :ssl

    def initialize(url, username, password)
      @url, @username, @password  = url, username, password
    end

    def valid?
      !url.nil? && !username.nil? && !password.nil?
    end

    def basic_auth
      Base64.encode64("#{username}:#{password}").delete("\r\n")
    end

    def host
      @url
    end
  end
end
