module RainForest
  class Base
    def initialize
      region =  ENV['rainforest_region']
      credentials = Aws::Credentials.new(ENV['rainforest_akid'], ENV['rainforest_secret'])
      @bucket = ENV['rainforest_bucket']
      return Aws::S3::Client.new(region: region,  credentials: credentials)
    end
  end
end
