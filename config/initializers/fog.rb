CarrierWave.configure do |config|
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
        provider:              'AWS',
        aws_access_key_id:     ENV['AWS_ACCESS_KEY'],
        aws_secret_access_key: ENV['AWS_SEC_KEY'],
        region:                'ap-northeast-1',
        endpoint:              'https://s3-ap-northeast-1.amazonaws.com'
    }
    config.fog_directory  = 'fullout-linemanager-storage'
    config.fog_public     = true
    config.fog_attributes = { }

    # auto delete in the AWS S3
    config.remove_previously_stored_files_after_update = true
end
