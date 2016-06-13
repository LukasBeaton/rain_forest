require 'rubygems'
require 'bundler'
Bundler.require(:development)

require 'coveralls'
Coveralls.wear!

require 'rain_forest'

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_adapter 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ENV["RAIN_FOREST_AWS_AKID"]    = "DUMMY_RAIN_FOREST_AWS_AKID"
ENV["RAIN_FOREST_AWS_SECRET"]  = "DUMMY_RAIN_FOREST_AWS_SECRET"
ENV["RAIN_FOREST_AWS_REGION"]  = "DUMMY_RAIN_FOREST_AWS_REGION"
ENV["RAIN_FOREST_AWS_BUCKET"]  = "DUMMY_RAIN_FOREST_AWS_BUCKET"

RSpec.configure do |config|
end
