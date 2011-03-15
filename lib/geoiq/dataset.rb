class Geoiq
  class Dataset < BaseModel
    api_methods crud + %w(features csv_upload)

    attr_accessor :geoiq_id, :title, :description, :tags, :published, :data_type, :feature_count, :link, :json

    def attributes
      %w{title description tags published data_type feature_count link}
    end

    def initialize(auth, options = {})
      self.geoiq_id = options.delete(:geoiq_id) if options.include?(:geoiq_id)
      self.title = options[:title] || "Untitled"
      self.description = options[:description] || ""
      self.tags = options[:tags] || ""
      super
    end

    # datasets.find(123)
    def find(id, options={})
      options = {:include_geometry=>0}
      response = request(:get, "/datasets/#{id}.json", {:query => options})
      dataset = Geoiq::Dataset.parse(response, auth, {:geoiq_id => id})
      dataset
    end

    def update(options)
      requires_geoiq_id
      self.title ||= options[:title]
      self.description ||= options[:description]
      self.tags ||= options[:tags]
      self.attributes ||= options[:attributes]
      overlay = {:overlay => options}
      response = request(:put, "/datasets/#{self.geoiq_id}.json", {:query => overlay})
      return true if response["status"].to_i == 200 || response["status"].to_i == 201
    end

    def delete
      requires_geoiq_id
      response = request(:delete, "/datasets/#{self.geoiq_id}.json")
      return true if response["status"].to_i == 204
    end


    def features(options={})
      requires_geoiq_id
   
      response = request(:get, "/datasets/#{self.geoiq_id}/features.json", {:query => options})
      features = JSON.parse(response.body)
   

    end

    def csv_upload(filename,  options={})
      type = "text/csv"

      content = File.read(filename)
      response = request(:post, "/datasets.json",
        {:body => content,
          :headers =>{ "Content-Type" => "#{type}"},
          :query => options})

      id =  response.headers["location"].match(/(\d+)\.json/)[1].to_i

      return find(id)
    end

    def shp_upload(shp_file, dbf_file, shx_file)

      body = shp_upload_body(shp_file, dbf_file, shx_file)
        response = request(:post, "/datasets.json",
        {:body => body,
          :headers =>{ "Content-Type" => "multipart/form-data, boundary=89d6e3836995"}
         })
      id =  response.headers["location"].match(/(\d+)\.json/)[1].to_i

      return find(id)

    end


    def shp_upload_body(shp_file, dbf_file, shx_file)
      boundary = "89d6e3836995"
      
      body = []

      body << "--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"dataset[shp]\"; filename=\"#{File.basename(shp_file)}\"\r\n"
      body << "Content-Type: application/octet-stream\r\n"
      body << "\r\n"
      body << File.read(shp_file)

      body << "\r\n--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"dataset[dbf]\"; filename=\"#{File.basename(dbf_file)}\"\r\n"
      body << "Content-Type: application/octet-stream\r\n"
      body << "\r\n"
      body << File.read(dbf_file)

      body << "\r\n--#{boundary}\r\n"
      body << "Content-Disposition: form-data; name=\"dataset[shx]\"; filename=\"#{File.basename(shx_file)}\"\r\n"
      body << "Content-Type: application/octet-stream\r\n"
      body << "\r\n"
      body << File.read(shx_file)

      body << "\r\n--#{boundary}--\r\n"

      body.join
    end

  end
end

