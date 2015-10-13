require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

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

ENV["rainforest_aws_akid"]    = "DUMMY_rainforest_aws_akid"
ENV["rainforest_aws_secret"]  = "DUMMY_rainforest_aws_secret"
ENV["rainforest_aws_region"]  = "DUMMY_rainforest_aws_region"
ENV["rainforest_aws_bucket"]  = "DUMMY_rainforest_aws_bucket"

RSpec.configure do |config|
end
