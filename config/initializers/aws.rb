if Rails.env.development?
  Aws.config.update(
    endpoint: 'http://localstack:4572',
    credentials: Aws::Credentials.new('qwerty', 'qwerty'),
    region: 'us-east-1',
    force_path_style: true,
  )
end
