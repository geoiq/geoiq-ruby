require 'rubygems'
require File.dirname(__FILE__) + '/../lib/geoiq.rb'

#
#
# Little scratch file with examples for trying out the library
#
#

geoiq = Geoiq.client("http://localhost.local", "admin", "password")
dataset = geoiq.dataset.find(2288)
#2284

analysis = geoiq.analysis.create({:calculation => "intersect", :ds1 => 2288, :ds2 => 2284 })
p analysis 
#p dataset.json
#p dataset.geoiq_id
#features = dataset.features
#
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
