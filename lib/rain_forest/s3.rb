require 'aws-sdk'

module RainForest 
  class S3 
    attr_accessor :bucket, :client

    def initialize
      region = ENV['RAIN_FOREST_AWS_REGION']
      region = ENV['rain_forest_aws_region'] if region.nil?#fallback to older config

      akid = ENV['RAIN_FOREST_AWS_AKID']
      akid = ENV['rain_forest_aws_akid'] if akid.nil?#fallback to older config

      secret = ENV['RAIN_FOREST_AWS_SECRET']
      secret = ENV['rain_forest_aws_secret'] if secret.nil?#fallback to older config

      bucket = ENV['RAIN_FOREST_AWS_BUCKET']
      bucket = ENV['rain_forest_aws_bucket'] if bucket.nil?#fallback to older config

      credentials = ::Aws::Credentials.new(akid, secret)
      @bucket = ENV['RAIN_FOREST_AWS_BUCKET']
      @client = ::Aws::S3::Client.new(region: region,  credentials: credentials)
    end

    def self.write(storage_key, data, options={})
      self.new.write(storage_key, data, options)
    end

    def self.read(storage_key)
      self.new.read(storage_key)
    end

    def self.copy(source_key, dest_key)
      self.new.copy(source_key, dest_key)
    end

    def self.move(source_key, dest_key)
      self.new.move(source_key, dest_key)
    end

    def self.content_length(storage_key)
      self.new.content_length(storage_key)
    end

    def self.delete_objects(prefix)
      self.new.delete_objects(prefix)
    end

    def self.set_index_document(index_document)
      self.new.set_index_document(index_document)
    end

    def write(storage_key, data, options={})
      attrs = {
        bucket: @bucket,
        key: storage_key,
        body: data,
        acl: 'public-read'
      }.merge(options)

      begin
        @client.put_object(attrs)
      rescue Exception => e
        return false, e.message 
      end

      return true, nil
    end

    def read(storage_key)
      begin
        resp = @client.get_object(bucket: @bucket, key: storage_key)
        return true, resp.body.read
      rescue Exception => e
        return false, e.message
      end
    end

    def copy(source_key, dest_key)
      begin
        @client.copy_object(bucket: @bucket, copy_source: "#{@bucket}/#{source_key}", key: dest_key)
      rescue Exception => e
        return false, e.message
      end
      
      return true, nil
    end

    def move(source_key, dest_key)
      begin
        @client.copy_object(bucket: @bucket, copy_source: "#{@bucket}/#{source_key}", key: dest_key)
        @client.delete_object(bucket: @bucket, key: source_key)
      rescue Exception => e
        return false, e.message
      end
      
      return true, nil
    end

    def content_length(storage_key)
      begin
        resp = @client.head_object(bucket: @bucket, key: storage_key)
        return resp.content_length
      rescue Exception
        return -1
      end
    end

    def delete_objects(prefix)
      begin
        objects_deleted = 0
        resp = @client.list_objects(bucket: @bucket, prefix: prefix)
        
        if resp.contents.length > 0
          objects = resp.contents.map{|f| {key: f.key}}
          resp = @client.delete_objects(bucket: @bucket, delete: {objects: objects})
          objects_deleted += resp.deleted.length
        end

        return objects_deleted
      rescue Exception
        return -1
      end
    end    

    def set_index_document(index_document)
      begin
        resp = @client.put_bucket_website(
          bucket: @bucket,
          content_md5: "",
          website_configuration: {
            index_document: {
              suffix: index_document
            }
          }
        )
      rescue Exception => e
        return false, e.message
      end
      
      return true, nil
    end
  end
end
