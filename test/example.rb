require 'rubygems'
require File.dirname(__FILE__) + '/../lib/geoiq-gem'

# Geoiq::base_uri = "http://geoiq.local"
# d =  Geoiq::Dataset.load(864)
# p d.features({:limit => 2}).size

# Dataset creation
# dataset = Geoiq::Dataset.new(:title => "Plotting our houses", :attributes => [{:name => "comments", :type => "string"}, {:name => "timestamp", :type => "datetime"}])
# puts dataset.create

# Feature creation
# d = Geoiq::Dataset.load(1656)
# d.add([{:comment => "Second comment", :timestamp => Time.now, :geometry => {:type => "Point", :coordinates => [-80,-20]}}])