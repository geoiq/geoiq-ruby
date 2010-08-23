module Geoiq
  class Dataset < Mapject

    attr_accessor :object_path
    attr_accessor :geoiq_id, :title, :tags
    
    def self.attributes
      %w{title description tags basemap extent}
    end
        
    def initialize(options = {})
      self.object_path = "/datasets"
      self.geoiq_id = options.delete(:id) if options.include?(:id)
      self.title = self.title || "Untitled"
      self.tags = (self.tags || []).join(",")

      # self.attributes = options.merge!({:query => {:url => "http://earthquake.usgs.gov/eqcenter/catalogs/1day-M2.5.xml"}})
    end
    
    def upload_data(data, type = "text/csv")
      path = self.geoiq_id.nil? ? "" : "/#{self.geoiq_id}"
      request = send_post("#{self.object_path}#{path}.json", 
        { :header => {"Content-Type" => "#{type}"},
          :body => data, :options_as_array => true})
    end
  end
end