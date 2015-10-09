module RainForest 
  class S3 < Base 
    def initialize
      super
    end

    def self.write(storage_key, data, permission='public-read')
      client = self.new
      begin
        client.put_object(bucket: @bucket, key: storage_key, body: data, acl: permission)
      rescue Exception => e
        return false, e.message 
      end

      return true, nil
    end

    def self.read(storage_key)
      client = self.new
      begin
        resp = client.get_object(bucket: @bucket, key: storage_key)
        return true, resp.body.read
      rescue Exception => e
        return false, e.message
      end
    end

    def self.move(source_key, dest_key)
      begin
        client.copy_object(bucket: @bucket, copy_source: "#{@bucket}/#{source_key}", key: dest_key)
        client.delete_object(bucket: @bucket, key: source_key)
      rescue Exception => e
        return false, e.message
      end
      
      return true, nil
    end

    def self.content_length(storage_key)
      client = self.new
      begin
        resp = client.head_object(bucket: @bucket, key: storage_key)
        return resp.content_length
      rescue Exception
        return -1
      end
    end

    def self.delete_objects(prefix)
      client = self.new
      begin
        objects_deleted = 0
        resp = client.list_objects(bucket: @bucket, prefix: prefix)
        
        if resp.contents.length > 0
          objects = resp.contents.map{|f| {key: f.key}}
          resp = client.delete_objects(bucket: @bucket, delete: {objects: objects})
          objects_deleted += resp.deleted.length
        end

        return objects_deleted
      rescue Exception
        return -1
      end
    end    
  end
end
