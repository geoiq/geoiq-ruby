require 'httparty'
require 'pathname'
require 'uri'

dir = Pathname(__FILE__).dirname.expand_path

require dir + "lib/geoiq"
require dir + "lib/map"
require dir + "lib/dataset"
require dir + "lib/search"