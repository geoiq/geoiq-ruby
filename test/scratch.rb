require 'rubygems'
require File.dirname(__FILE__) + '/../lib/geoiq.rb'

#
#
# Little scratch file for trying out the library
#
#

geoiq = Geoiq.client("http://localhost.local", "admin", "password")
dataset = geoiq.dataset.find(1348)
#p dataset.json
#p dataset.geoiq_id
#features = dataset.features
features = dataset.features({:hex_geometry => 0})
p features
#
#p features.size
#p dataset
#p dataset.update({:title => "poo"})
#
#p dataset.title
#
#p dataset

#results = geoiq.search("wms", {:limit => 2})
#p results


#map = geoiq.map(:title => "poo")
#p map.attributes
#p map.title
#p map.create
