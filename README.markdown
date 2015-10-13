# Rain Forest: an AWS ecosystem

Rain Forest is a collection of simplified adaptors for Amazon Web Services and relies on the [aws-sdk Gem](https://rubygems.org/gems/aws-sdk). The intention is for Rain Forest to one day support many of Amazon's web services. However, at the moment there is only support for S3.

## Installation

Use Ruby Gems to install rain_forest to get started:

    $ gem install rain_forest

There are 4 ENVIRONMENT variables which are used to configure Rain Forest to your AWS account.

    ENV["rainforest_aws_akid"]    = "YOUR_ACCESS_KEY_ID"
    ENV["rainforest_aws_secret"]  = "YOUR_SECRET_ACCESS_KEY"
    ENV["rainforest_aws_region"]  = "YOUR_BUCKET_REGION"
    ENV["rainforest_aws_bucket"]  = "YOUR_BUCKET"


## Contributing to rain_forest
 
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

