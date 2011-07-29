class Geoiq
  class Map < BaseModel
    api_methods crud + %w(add_layer)

    attr_accessor :geoiq_id, :title, :description, :tags, :basemap, :published, :extent, :layers, :json

    def attributes
      %w{title description tags basemap extent layers}
    end

    def initialize(auth, options={})
      self.geoiq_id = options.delete(:geoiq_id) if options.include?(:geoiq_id)
      self.title = options[:title] || "Untitled Map"
      self.tags = (options[:tags] || []).join(",")
      self.extent = options[:extent] || [-180,-90,180,90]
      self.basemap = options[:basemap] || "Acetate"
      self.layers = options[:layers] || []
      super
    end

    def find(id, options={})
      response = request(:get, "/maps/#{id}.json", {:query => options})
      map = Geoiq::Map.parse(response, auth, {:geoiq_id => id})
      map
    end

    def create(options={})
      self.attributes.each do |a|
        options.merge!({a => self.send(a)})
      end
      
      response = request(:post, "/maps.json", {:query => options})
      
      id =  response.headers["location"].match(/(\d+)\.json/)[1].to_i

      return find(id)
    end

    def update(options={})
      requires_geoiq_id
      response = request(:put, "/maps/#{self.geoiq_id}.json", {:query => options})
      return true if response["status"].to_i == 200 || response["status"].to_i == 201
    end

    def delete
      requires_geoiq_id
      response = request(:delete, "/maps/#{self.geoiq_id}.json")
      return true if response["status"].to_i == 204
    end

    # layers are an array of ids of datasets to add
    def add_layer(layer)
      requires_geoiq_id
      options = {:source => "finder:#{layer}"}
      response = request(:post, "/maps/#{self.geoiq_id}/layers.json", {:query => options})
      layer_index = response.headers["location"].match(/(\d+)\.json/)[1].to_i
      return layer_index if response["status"].to_i == 201
    end



  end
end