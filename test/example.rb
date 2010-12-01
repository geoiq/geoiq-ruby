require 'rubygems'
require 'geoiq-gem'

d =  Geoiq::Dataset.load(864)
p d.features({:limit => 2}).size
