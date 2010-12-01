require 'httparty'
require 'pathname'
require 'uri'

dir = Pathname(__FILE__).dirname.expand_path

require dir + "geoiq/geoiq"
require dir + "geoiq/map"
require dir + "geoiq/dataset"
require dir + "geoiq/search"

