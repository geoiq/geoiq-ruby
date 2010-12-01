module Geoiq
  class Layer < Mapject

    attr_accessor :object_path
    attr_accessor :geoiq_id
    
    def self.attributes
      %w{title description tags basemap extent}
    end
        
    def initialize(options = {})
      self.object_path = "/layers"
      self.geoiq_id = options.delete(:id) if options.include?(:id)
      self.title = self.title || "Untitled"

      # self.attributes = options.merge!({:query => {:url => "http://earthquake.usgs.gov/eqcenter/catalogs/1day-M2.5.xml"}})
    end
    
  end
end