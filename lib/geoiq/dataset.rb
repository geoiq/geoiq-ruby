module Geoiq
  class Dataset < Mapject

    attr_accessor :object_path
    attr_accessor :geoiq_id, :title, :description, :tags, :features, :attributes
    
    def self.attributes
      %w{title description tags}
    end
        
    def initialize(options = {})
      self.object_path = "/datasets"
      self.geoiq_id = options.delete(:geoiq_id) if options.include?(:geoiq_id)
      self.title = options[:title] || "Untitled"
      self.description = options[:desciption] || ""
      self.tags = options[:tags] || ""
      self.attributes = options[:attributes] || {}
    end

    def features(options = {})
      options = options.merge!({:include_features => 1})
      request = send_get("#{self.object_path}/#{self.geoiq_id}/features.json", {:query => options})
      respond_to_status(request)

      return request.parsed_response
    end
    
    def create
      data = {:title => self.title, :description => self.description, :tags => self.tags, :attributes => self.attributes }
      request = send_post("#{self.object_path}.json", { :headers => {"Content-Type" => "application/json"},
            :body => data, :options_as_array => true})

      if request["status"].to_i == 201 && self.geoiq_id.nil?
        self.geoiq_id = request["location"].match(/(\d+)\.json/)[1]
      end
  
      respond_to_status(request)
      
      return request.parsed_response
    end
    
    def add(features = [])      
      request = send_post("#{self.object_path}/#{self.geoiq_id}/features.json", { :headers => {"Content-Type" => "application/json"}, :body => features.to_json, :options_as_array => true})
      respond_to_status(request)

      return request.parsed_response
    end
    
    # Call a GeoIQ calculation. Returns the id of the resulting dataset.
    def calculate(algorithm, inputs )
      raise "Dataset must be saved for calculation" if self.geoiq_id.nil?
      
      options = { :query => {
                    :algorithm => algorithm,
                    :input => inputs,
                    :include_features => 0
                  }}
      request = send_post("#{self.object_path}/#{self.geoiq_id}/calculate.json", options)
      respond_to_status(request)            

      return request.parsed_response["id"].to_i
    end

    # Call a GeoIQ calculation. Returns the id of the resulting dataset.
    # 
    # merging_overlay takes either an integer ID or a Geoiq::Dataset
    def merge( merging_overlay )
      raise "Dataset must be saved for merging" if self.geoiq_id.nil?
      merging_overlay = merging_overlay.geoiq_id if merging_overlay.is_a?(Geoiq::Dataset)
      
      options = { :query => {
                    :merge => merging_overlay.to_i,
                    :include_features => 0                    
                  }}
      request = send_post("#{self.object_path}/#{self.geoiq_id}/merge.json", options)
      respond_to_status(request)            

      return request.parsed_response["id"].to_i
    end    
    def upload_data(data, type = "text/csv")
      if self.geoiq_id.nil?
        request = send_post("#{self.object_path}.json?title=#{URI.escape(self.title)}&tags=#{URI.escape(self.tags)}", 
          { :headers => {"Content-Type" => "#{type}"},
            :body => data, :options_as_array => true})
      else
        request = send_put("#{self.object_path}/#{self.geoiq_id}/features.json",
          { :headers => {"Content-Type" => "#{type}"},
            :body => data, :options_as_array => true})
      end
      
      if request["status"].to_i == 201 && self.geoiq_id.nil?
        self.geoiq_id = request["location"].match(/(\d+)\.json/)[1]
      end
      respond_to_status(request)            

      return self.geoiq_id
    end
  end
end