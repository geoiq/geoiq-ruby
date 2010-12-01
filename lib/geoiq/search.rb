module Geoiq
  class Search < Mapject
    
    attr_accessor :object_path
    def initialize
      self.object_path = "/search"
    end
    
    
  end
end