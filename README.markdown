# Rain Forest: an AWS ecosystem

Rain Forest is a collection of simplified adaptors for Amazon Web Services and relies on the [aws-sdk Gem](https://rubygems.org/gems/aws-sdk). The intention is for Rain Forest to one day support many of Amazon's web services. However, at the moment there is only support for S3.

## Installation

Use Ruby Gems to install rain_forest to get started:

    $ gem install rain_forest

There are 4 ENVIRONMENT variables which are used to configure Rain Forest to your AWS account:

    ENV["rain_forest_aws_akid"]    = "YOUR_ACCESS_KEY_ID"
    ENV["rain_forest_aws_secret"]  = "YOUR_SECRET_ACCESS_KEY"
    ENV["rain_forest_aws_region"]  = "YOUR_BUCKET_REGION"
    ENV["rain_forest_aws_bucket"]  = "YOUR_BUCKET"

In a typical Rails environment you could use a YML file and an initializer to configure Rain Forest as follows:

config/rain_forest.yml
    rain_forest:
      development:
        aws_akid: "YOUR_ACCESS_KEY_ID"
        aws_secret: "YOUR_SECRET_ACCESS_KEY"
        aws_region: "YOUR_BUCKET_REGION"
        aws_bucket: "YOUR_BUCKET"
      test:
        aws_akid: "YOUR_ACCESS_KEY_ID"
        aws_secret: "YOUR_SECRET_ACCESS_KEY"
        aws_region: "YOUR_BUCKET_REGION"
        aws_bucket: "YOUR_BUCKET"
      production:
        aws_akid: "YOUR_ACCESS_KEY_ID"
        aws_secret: "YOUR_SECRET_ACCESS_KEY"
        aws_region: "YOUR_BUCKET_REGION"
        aws_bucket: "YOUR_BUCKET"

config/initializers/rain_forest.rb
    config = YAML.load_file("#{Rails.root}/config/rain_forest.yml")
    environment = Rails.env || "development"

    options = config['rain_forest'][environment]
    options.each do |k,v|
      ENV["rain_forest_#{k}"] = v
    end

## Available Methods
    RainForest::S3.write(storage_key, data, permission='public-read')
    RainForest::S3.read(storage_key)
    RainForest::S3.move(source_key, dest_key)
    RainForest::S3.content_length(storage_key)
    RainForest::S3.delete_objects(prefix)
    

## Contributing to Rain Forest 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Lukas Beaton. See LICENSE.txt for
further details.

