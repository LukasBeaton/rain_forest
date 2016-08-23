require 'spec_helper'

describe RainForest::CloudFront do
  let(:credentials){ double("AWS Crendetials") }
  let(:client){ double("AWS Client") }

  let(:cloudfront_distribution){ 
    {
      etag: 'ETAG',
      distribution: {
        distribution_config: {
          comment: nil,
          logging: {
            bucket: nil,
            prefix: nil
          },
          origins: {
            items: [
              {origin_path: 'OLD_ORIGIN' }
            ]
          }
        }
      }
    }
  }

  before do
    expect(::Aws::CloudFront::Client).to receive(:new).with(access_key_id: ENV["RAIN_FOREST_AWS_AKID"], secret_access_key: ENV["RAIN_FOREST_AWS_SECRET"], region: 'cloudfront.amazonaws.com').and_return(client).at_least(:once)
  end

  describe "#update_origin" do
    it "works with default public-read permissions" do
      expected_config = { 
        comment: '',
        logging: {
          bucket: '',
          prefix: ''
        },
        origins: {
          items: [
            {origin_path: '/NEW_ORIGIN' }
          ]
        }
      }

      expect(client).to receive(:get_distribution).with(id: 'DISTRIBUTION_ID').and_return(cloudfront_distribution)
      expect(client).to receive(:update_distribution).with(id: 'DISTRIBUTION_ID', if_match: 'ETAG', distribution_config: expected_config)

      success, message = RainForest::CloudFront.update_origin('DISTRIBUTION_ID', "/NEW_ORIGIN")

      expect(message).to eq(nil)
      expect(success).to eq(true)
    end

    it "handles errors" do
      expect(client).to receive(:get_distribution).with(id: 'DISTRIBUTION_ID').and_return(cloudfront_distribution)
      expect(client).to receive(:update_distribution).and_raise(Exception.new("KABOOM!"))

      success, message = RainForest::CloudFront.update_origin('DISTRIBUTION_ID', "/NEW_ORIGIN")

      expect(message).to eq("KABOOM!")
      expect(success).to eq(false)
    end
  end

  describe "#get_distribution" do
    let(:distribution){
      OpenStruct.new(
        distribution: OpenStruct.new(id: "DISTRIBUTION_ID", status: "InProgress")
      )
    }

    it "works" do
      expect(client).to receive(:get_distribution).with(id: 'DISTRIBUTION_ID').and_return(distribution)

      success, message_or_object = RainForest::CloudFront.get_distribution('DISTRIBUTION_ID')

      expect(message_or_object).to eq(distribution)
      expect(success).to eq(true)
    end

    it "handles errors" do 
      expect(client).to receive(:get_distribution).with(id: 'DISTRIBUTION_ID').and_raise(Exception.new("KABOOM!"))

      success, message_or_object = RainForest::CloudFront.get_distribution('DISTRIBUTION_ID')

      expect(message_or_object).to eq("KABOOM!")
      expect(success).to eq(false)
    end

    describe "#get_distribution_status" do
      it "works" do
        expect(client).to receive(:get_distribution).with(id: 'DISTRIBUTION_ID').and_return(distribution)

        success, message_or_status = RainForest::CloudFront.get_distribution_status('DISTRIBUTION_ID')

        expect(message_or_status).to eq("InProgress")
        expect(success).to eq(true)
      end

      it "handles errors" do 
        expect(client).to receive(:get_distribution).with(id: 'DISTRIBUTION_ID').and_raise(Exception.new("KABOOM!"))

        success, message_or_status = RainForest::CloudFront.get_distribution_status('DISTRIBUTION_ID')

        expect(message_or_status).to eq("KABOOM!")
        expect(success).to eq(false)
      end
    end
  end



  describe "#create_invalidation" do
    before do
      expect(SecureRandom).to receive(:hex).with(16).and_return("A_RANDOM_CALLER_REFERENCE")
    end

    let(:aws_response_object){double("AWS Response Object")}
    
    it "created an invalidation" do
      expected_parameters = {
        distribution_id: "DISTRIBUTION_ID",
        invalidation_batch: {
          paths: {
            quantity: 3,
            items: ["FIRST_PATH", "SECOND_PATH", "THIRD_PATH"]
          },
          caller_reference: "A_RANDOM_CALLER_REFERENCE"
        }
      }

      expect(client).to receive(:create_invalidation).with(expected_parameters).and_return(aws_response_object)

      success, message_or_object = RainForest::CloudFront.create_invalidation("DISTRIBUTION_ID", ["FIRST_PATH", "SECOND_PATH", "THIRD_PATH"])

      expect(message_or_object).to eq(aws_response_object)
      expect(success).to eq(true)
    end

    it "handles errors" do
      expect(client).to receive(:create_invalidation).and_raise(Exception.new("KABOOM!"))

      success, message = RainForest::CloudFront.create_invalidation("DISTRIBUTION_ID", ["FIRST_PATH", "SECOND_PATH", "THIRD_PATH"])

      expect(message).to eq("KABOOM!")
      expect(success).to eq(false)
    end
  end
end
