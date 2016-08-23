require 'aws-sdk'
require 'securerandom'

module RainForest 
  class CloudFront 
    attr_accessor :client

    def initialize
      akid = ENV['RAIN_FOREST_AWS_AKID']
      secret = ENV['RAIN_FOREST_AWS_SECRET']
      @client = ::Aws::CloudFront::Client.new(access_key_id: akid, secret_access_key: secret, region: 'cloudfront.amazonaws.com')
    end

    def self.get_distribution(distribution_id)
      self.new.get_distribution(distribution_id)
    end

    def self.update_origin(distribution_id, new_origin_key)
      self.new.update_origin(distribution_id, new_origin_key)
    end

    def self.create_invalidation(distribution_id, invalidate_paths_array)
      self.new.create_invalidation(distribution_id, invalidate_paths_array)
    end

    def get_distribution(distribution_id)
      begin
        dist = @client.get_distribution(id: distribution_id)
        return true, dist
      rescue Exception => e
        return false, e.message
      end
    end

    def update_origin(distribution_id, new_origin_key)
      begin
        dist = @client.get_distribution(id: distribution_id)
        
        dist_config = dist[:distribution][:distribution_config]
        dist_config[:comment] = dist_config[:comment].to_s #ensure not nil or will get an error
        dist_config[:logging][:bucket] = dist_config[:logging][:bucket].to_s #ensure not nil or will get an error
        dist_config[:logging][:prefix] = dist_config[:logging][:prefix].to_s #ensure not nil or will get an error
        
        dist_config[:origins][:items][0][:origin_path] = new_origin_key # IMPORTANT: set new origin!
        
        options = {
          id: distribution_id,
          if_match: dist[:etag],
          distribution_config: dist_config
        }

        @client.update_distribution(options)
      rescue Exception => e
        return false, e.message
      end
      
      return true, nil
    end

    def create_invalidation(distribution_id, invalidate_paths_array, caller_reference=::SecureRandom.hex(16))
      begin
        parameters = {
          distribution_id: distribution_id,
          invalidation_batch: {
            paths: {
              quantity: invalidate_paths_array.count,
              items: invalidate_paths_array
            },
            caller_reference: caller_reference
          }
        }

        resp = @client.create_invalidation(parameters)

        return true, resp
      rescue Exception => e
        return false, e.message
      end
    end
  end
end
