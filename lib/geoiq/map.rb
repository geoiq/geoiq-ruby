module Geoiq
  class Map < Mapject
    
    attr_accessor :object_path
    attr_accessor :geoiq_id,:title,:description,:tags,:basemap,:extent,:layers
    
    def self.attributes
      %w{title description tags basemap extent layers}
    end
    
    def initialize(options = {})
      self.object_path = "/maps"
      self.geoiq_id = options.delete(:id) if options.include?(:id)
      self.title = self.title || "Untitled"
      self.tags = (self.tags || []).join(",")
      self.extent = self.extent || [-180,-90,180,90]
      self.basemap = "OpenStreetMap (Road)"
      self.layers = []
    end

    def self.create_map_with_dataset
      # create_finder_source
      map = Map.new
      map.create
      map.add_layer(map.dataset)
      return map
    end
    
    def self.load(id)
      map = Map.new(:id => id)
      map.load
      map
    end
  
    def add_layer(dataset, options = {})
      source_id = dataset.is_a?(Dataset) ? dataset.geoiq_id : dataset
      options.merge!({:query => {
        :title => "Test", 
        :subtitle => "Testing",
        :source => "finder:#{source_id}",
        :visible => true,
        :opacity => 1.0,
        :styles => {
          :icon => {
            :symbol => "circle", 
            :size => 3
          }
        }
      }})
      request = send_post("#{self.object_path}/#{self.geoiq_id}/layers.json", options, :options_as_array => true)
      # raise request.inspect.to_s
      respond_to_status(request)
    end
      
  end
end