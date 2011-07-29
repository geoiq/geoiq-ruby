class Geoiq
  class Analysis < BaseModel
    

    def initialize(auth, options={})
      super
    end

    def create(options={})
      response = request(:post, "/analysis.json", {:query => options})
      id =  response.headers["location"].match(/(\d+)\.json/)[1].to_i
      
      return  Geoiq::Dataset.new(auth).find(id)
    end


   

  end

end