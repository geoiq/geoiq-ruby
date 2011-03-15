require 'httparty'
require 'pathname'
require 'uri'
require 'json'
require 'base64'

dir = Pathname(__FILE__).dirname.expand_path
require dir+"geoiq/auth"

require dir+"geoiq/base_model"
require dir+"geoiq/errors"
require dir+"geoiq/search"
require dir+"geoiq/map"
require dir+"geoiq/dataset"


class Geoiq
  attr_reader :request, :auth, :api_methods

  def initialize(url, username, password, options = {})
   # @api_methods = %w(clients contacts projects tasks people)
    @api_methods = %w(dataset search map)
    
    @auth = Auth.new(url, username, password)
  #  raise InvalidCredentials unless credentials.valid?
  end

  def dataset
    @dataset||= Geoiq::Dataset.new(auth)
  end

  def search(query, options={}, format='json')
    Geoiq::Search.new(auth).search(query, options, format)
  end

  def map(options={})
    Geoiq::Map.new(auth, options)
  end


  class << self
    def client(url, username, password, options = {})
      new(url, username, password, options)
    end
end

end

