require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'fakeweb'
require 'geo_ruby'
require 'json'

#FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https?://admin:password@localhost.local/*]

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'geoiq'

class Test::Unit::TestCase
end

def geoiq_url(url)
  url =~ /^http/ ? url : "http://geocommons.com#{url}"
end

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def binary_file_fixture(filename)
  File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
end

def stub_get(url, filename, options={})
  opts = {:body => fixture_file(filename)}.merge(options)
 # p geoiq_url(url)
  FakeWeb.register_uri(:get, geoiq_url(url), opts)
end

def stub_post(url, filename)
  FakeWeb.register_uri(:post, geoiq_url(url), :body => fixture_file(filename))
end

def stub_delete(url, filename)
  FakeWeb.register_uri(:delete, geoiq_url(url), :body => fixture_file(filename))
end

def stub_put(url, filename)
  FakeWeb.register_uri(:put, geoiq_url(url), :body => fixture_file(filename))
end