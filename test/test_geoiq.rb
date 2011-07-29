require 'helper'

class TestGeoiq < Test::Unit::TestCase

  GEOIQ_URL = "http://geocommons.com"
  USERNAME = "wobble"
  PASSWORD = "wibble"

  context "when unauthenticated" do #(and configured to allow unauthenticated logins)
    setup do
      @geoiq = Geoiq.client("http://geocommons.com", "wobble", "wibble")
    end

    context "a dataset" do
      setup do
        stub_get("http://wobble:wibble@geocommons.com/datasets/71480.json?include_geometry=0", "ustates2.json")
        @dataset = @geoiq.dataset.find("71480")
      end

      should "be correct" do
        assert_kind_of(Geoiq::Dataset, @dataset)
        assert_equal "ustates2", @dataset.title
      end

      context "with all features" do
        setup do
          stub_get("http://wobble:wibble@geocommons.com/datasets/71480/features.json?", "features.json")
          @feature_count = @dataset.feature_count
          @features = @dataset.features
          assert_not_nil @features
          assert_kind_of(Array, @features)
        end

        should "have the correct count of features" do
          #p @feature_count (87)
          assert_equal @feature_count, @features.size
        end

        should "have correct features with correct geometry" do
          assert_equal "Virginia", @features.first["NAME"]
          assert_not_nil @features.first["geometry"]
          @geom = GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(@features.first["geometry"])
          assert_kind_of GeoRuby::SimpleFeatures::MultiPolygon, @geom
        end

      end

      context "getting various filters on features" do

        setup do
          stub_get("http://wobble:wibble@geocommons.com/datasets/71480/features.json?filter[PERIMETER][][max]=0.3", "filter_attr_features.json")
          stub_get("http://wobble:wibble@geocommons.com/datasets/71480/features.json?bbox=-87.2%2C33.4%2C-75.9%2C38.4", "filter_bbox_features.json")
        end

        should "filter features by attribute" do
          features = @dataset.features({"filter[PERIMETER][][max]" => 0.3})
          assert_not_nil features
          assert_equal 4, features.size
          assert_equal ["Virginia", "Rhode Island", "Washington", "Maryland"].sort, features.map { |f| f['NAME']}.sort
        end

        should "filter features by bbox" do
          features = @dataset.features({:bbox => '-87.2,33.4,-75.9,38.4'})
          assert_equal 10, features.size
        end
      end
    end

    context "Searching" do

      setup do
        stub_get("http://wobble:wibble@geocommons.com/search.json?query=states", "search_states.json")
        stub_get("http://wobble:wibble@geocommons.com/search.json?query=points&bbox=-87.2%2C33.4%2C-75.9%2C38.4&limit=10", "search_states.json")
        stub_get("http://wobble:wibble@geocommons.com/search.json?query=tag%3Aeconomics", "search_tag_economics.json")
      end

      should "find anything" do
        results = @geoiq.search("states")
        assert_not_nil results
        assert_equal 14, results["totalResults"]
        assert_equal 10, results["entries"].size
      end


      should "find anything with bbox and limit" do
        results = @geoiq.search("points", {:bbox => '-87.2,33.4,-75.9,38.4', :limit=> 10})
        assert_not_nil results
        assert_equal 14, results["totalResults"]
        assert_equal 10, results["entries"].size
      end

      should "find stuff using a tag" do
        results = @geoiq.search("tag:economics")
        assert_not_nil results["entries"]
        assert_equal "action, canada, conservative, economic, funding, harper, minister, money, mps, party, plan, prime, spending, stephen", results["entries"].first["tags"]
      end


    end


  end

  #
  # TODO - Below this, use with fakeweb + fixtures
  #

  context "when authenticated with a CSV file uploaded" do
    setup do
      @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
      csv_file = 'data/sculptures.csv'
      @dataset = @geoiq.dataset.csv_upload(csv_file, {:title =>"garden sculptures"})
      assert_not_nil @dataset
      assert_equal "garden sculptures", @dataset.title
    end

    teardown do
      @dataset.delete
    end


    should "be able to get features" do
      features = @dataset.features
      assert_not_nil features
      assert_equal 20, features.size
    end

    should "be able to update it" do
      result = @dataset.update(:title => "Garden Scultures", :description => "lovely jubbly")
      assert_equal true, result
    end

    should "be able to delete it" do
      result = @dataset.delete
      assert_equal true, result
    end

  end

  context "when authenticated" do
    setup do
      @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
    end

    context "Shapefile upload" do

      setup do
        @dataset = @geoiq.dataset.shp_upload("data/simple.shp", "data/simple.dbf", "data/simple.shx")
      end

      teardown do
        @dataset.delete
      end

      should "be able to upload it and get the newly created dataset" do
        assert_not_nil @dataset
        assert_equal "simple", @dataset.title
      end

      should "be able to delete the dataset" do
        result = @dataset.delete
        assert_equal true, result
      end


    end

    context "Add a CSV dataset by URL" do
      setup do
        @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
        @dataset = @geoiq.dataset.url_upload("http://geothings.net/geoiq/simple_testing.csv", {:type => "csv"})
      end
      teardown do
        @dataset.delete
      end

      should "be able to be upload and get the newly created dataset" do
        assert_not_nil @dataset
        assert_equal "Untitled", @dataset.title
        assert_equal 4, @dataset.feature_count
      end

    end

    context "Add a WMS dataset by URL" do
      setup do
        @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
        @dataset = @geoiq.dataset.url_upload("http://tilecache.osgeo.org/wms-c/tilecache.py?request=GetCapabilities&service=WMS", {:type=>"wms", :title=>"Everyone loves WMS"})
      end
      teardown do
        @dataset.delete
      end

      should "be able to be upload and get the newly created dataset" do
        assert_not_nil @dataset
        assert_equal "Everyone loves WMS", @dataset.title
        assert_equal 'WMS', @dataset.data_type
      end

    end

    context "Add a Tile dataset by URL" do
      setup do
        @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
        @dataset = @geoiq.dataset.url_upload("http://otile1.mqcdn.com/tiles/1.0.0/osm/{Z}/{X}/{Y}.png", {:type=>"tile", :title=>"OpenStreetMap", :citation_url => "http://openstreetmap.org"})
      end
      teardown do
        @dataset.delete
      end

      should "be able to be upload and get the newly created dataset" do
        assert_not_nil @dataset
        assert_equal "OpenStreetMap", @dataset.title
        assert_equal "Tiles", @dataset.data_type
      end

    end

    context "Simple Analysis" do

     setup do
        @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
        @dataset = @geoiq.analysis.create({:calculation => "buffer", :ds1 => 2288, :distance => 50, :units => 'km'})
     end

      teardown do
        @dataset.delete
      end

      should "be able to do a buffer analysis" do
        assert_equal  "Dataset Analysis", @dataset.data_type
        assert_match  /buffer of 50m/ , @dataset.description
      end

    end

  end

  context "Maps" do

    setup do
      @geoiq = Geoiq.client(GEOIQ_URL, USERNAME, PASSWORD)
      map = @geoiq.map(:title => "my empty map")
      @geoiq_map = map.create
    end

    teardown do
      @geoiq_map.delete
    end

    should "be able to create map" do
      assert_not_nil @geoiq_map.geoiq_id
    end

    should "be able to get a map and it's layers" do
      @map = @geoiq.map.find(239)
      assert_not_nil @map.geoiq_id
      titles =  @map.layers.map{ |l| l['title']}
      assert_equal ["Roads", "Place Names", "garden sculptures"].sort, titles.sort
    end

    should "be able to add a layer to a map" do
      index  = @geoiq_map.add_layer(1466)
      assert_equal 0, index
    end

    should "be able to delete a map" do
      map = @geoiq.map(:title => "my empty map").create
      result = map.delete
      assert_equal true, result
    end
  end





end

