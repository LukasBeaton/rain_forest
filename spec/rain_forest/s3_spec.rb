require 'spec_helper'

describe RainForest::S3 do
  let(:credentials){ double("AWS Crendetials") }
  let(:client){ double("AWS Client") }

  before do
    expect(::Aws::Credentials).to receive(:new).with(ENV["RAIN_FOREST_AWS_AKID"], ENV["RAIN_FOREST_AWS_SECRET"]).and_return(credentials).at_least(:once)
    expect(::Aws::S3::Client).to receive(:new).with(region: ENV["RAIN_FOREST_AWS_REGION"], credentials: credentials).and_return(client).at_least(:once)
  end

  describe "#write" do
    it "works with default public-read permissions" do
      expect(client).to receive(:put_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY", body: "Some test data...", acl: "public-read").and_return(true)

      success, message = RainForest::S3.write("STORAGE-KEY", "Some test data...")

      expect(success).to eq(true)
      expect(message).to eq(nil)
    end

    it "accepts other options" do
      expect(client).to receive(:put_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY", body: "Some test data...", acl: "public-read", content_encoding: 'utf8').and_return(true)

      success, message = RainForest::S3.write("STORAGE-KEY", "Some test data...", content_encoding: 'utf8')

      expect(success).to eq(true)
      expect(message).to eq(nil)
    end

    it "handles errors" do
      expect(client).to receive(:put_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY", body: "Some test data...", acl: "public-read").and_raise(Exception.new("KABOOM!"))

      success, message = RainForest::S3.write("STORAGE-KEY", "Some test data...")

      expect(success).to eq(false)
      expect(message).to eq("KABOOM!")
    end
  end

  describe "#read" do
    let(:response_body){ double("Response Body", read: "Some test data...") }
    let(:response_object){ double("Response Object", body: response_body) }

    it "works" do
      expect(client).to receive(:get_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY").and_return(response_object)

      success, data = RainForest::S3.read("STORAGE-KEY")

      expect(success).to eq(true)
      expect(data).to eq("Some test data...")
    end

    it "handles errors" do
      expect(client).to receive(:get_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY").and_raise(Exception.new("KABOOM!"))

      success, data = RainForest::S3.read("STORAGE-KEY")

      expect(success).to eq(false)
      expect(data).to eq("KABOOM!")
    end
  end

  describe "#content_length" do
    let(:response_metadata){ double("Response Metadata", content_length: 12345) }

    it "works" do
      expect(client).to receive(:head_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY").and_return(response_metadata)

      response = RainForest::S3.content_length("STORAGE-KEY")

      expect(response).to eq(12345)
    end

    it "returns -1 for errors" do
      expect(client).to receive(:head_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "STORAGE-KEY").and_raise(Exception.new("KABOOM!"))

      response = RainForest::S3.content_length("STORAGE-KEY")

      expect(response).to eq(-1)
    end
  end

  describe "#delete_objects" do
    let(:content_1){ OpenStruct.new(key: "abc") }
    let(:content_2){ OpenStruct.new(key: "123") }
    let(:contents){ [content_1, content_2] }
    let(:objects_response){ double("Objects", contents: contents) }
    let(:deleted_response){ double("Deleted Objects", deleted: contents) }
    
    it "works and returns the number of delete objects" do
      expect(client).to receive(:list_objects).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], prefix: "SOME-PREFIX").and_return(objects_response)
      expect(client).to receive(:delete_objects).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], delete: {objects: [{key: "abc"}, {key: "123"}]}).and_return(deleted_response)

      result = RainForest::S3.delete_objects("SOME-PREFIX")

      expect(result).to eq(2)
    end
    
    it "returns -1 for errors" do
      expect(client).to receive(:list_objects).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], prefix: "SOME-PREFIX").and_raise(Exception.new("KABOOM!"))

      result = RainForest::S3.delete_objects("SOME-PREFIX")

      expect(result).to eq(-1)
    end
  end

  describe "#move" do
    it "works" do
      expect(client).to receive(:copy_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], copy_source: "#{ENV["RAIN_FOREST_AWS_BUCKET"]}/SOURCE-KEY", key: "DEST-KEY")
      expect(client).to receive(:delete_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], key: "SOURCE-KEY")

      success, message = RainForest::S3.move("SOURCE-KEY", "DEST-KEY")

      expect(success).to eq(true)
      expect(message).to eq(nil)
    end

    it "handles errors" do
      expect(client).to receive(:copy_object).and_raise(Exception.new("KABOOM!"))

      success, message = RainForest::S3.move("SOURCE-KEY", "DEST-KEY")

      expect(success).to eq(false)
      expect(message).to eq("KABOOM!")
    end
  end  

  describe "#copy" do
    it "works" do
      expect(client).to receive(:copy_object).with(bucket: ENV["RAIN_FOREST_AWS_BUCKET"], copy_source: "#{ENV["RAIN_FOREST_AWS_BUCKET"]}/SOURCE-KEY", key: "DEST-KEY")

      success, message = RainForest::S3.copy("SOURCE-KEY", "DEST-KEY")

      expect(success).to eq(true)
      expect(message).to eq(nil)
    end

    it "handles errors" do
      expect(client).to receive(:copy_object).and_raise(Exception.new("KABOOM!"))

      success, message = RainForest::S3.copy("SOURCE-KEY", "DEST-KEY")

      expect(success).to eq(false)
      expect(message).to eq("KABOOM!")
    end
  end

  describe "#set_index_document" do
    it "works" do
      expect(client).to receive(:put_bucket_website).with(
        bucket: ENV["RAIN_FOREST_AWS_BUCKET"], 
        website_configuration: {
          index_document: {
            suffix: "INDEX-DOCUMENT"
          }
        }
      )

      success, message = RainForest::S3.set_index_document("INDEX-DOCUMENT")

      expect(success).to eq(true)
      expect(message).to eq(nil)
    end

    it "handles errors" do
      expect(client).to receive(:put_bucket_website).and_raise(Exception.new("KABOOM!"))

      success, message = RainForest::S3.set_index_document("INDEX-DOCUMENT")

      expect(success).to eq(false)
      expect(message).to eq("KABOOM!")
    end
  end
end
