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
end
