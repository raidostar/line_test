CarrierWave.configure do |config|
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
      provider:              'AWS',
      aws_access_key_id:     ENV['AWS_ACCESS_KEY'],
      aws_secret_access_key: ENV['AWS_SEC_KEY'],
      region:                'ap-northeast-1',
      endpoint:              'https://s3-ap-northeast-1.amazonaws.com'
      # google_storage_access_key_id: ENV['GOOGLE_ACCESS_KEY'],
      # google_storage_secret_access_key: ENV['GOOGLE_SEC_KEY']
  }
  config.fog_directory  = 'fullout-linemanager-storage'
  config.fog_public     = true
  config.fog_attributes = { }
end