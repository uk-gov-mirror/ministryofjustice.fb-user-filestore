class SetS3LifecycleRules
  def call
    client.put_bucket_lifecycle_configuration({
      bucket: bucket,
      lifecycle_configuration: {
        rules: [
          {
            expiration: {
              days: 28,
            },
            filter: {
              prefix: "28d/",
            },
            id: "expire-28d",
            status: "Enabled"
          },
        ],
      },
    })
  end

  private

  def client
    @client ||= Aws::S3::Client.new
  end

  def bucket
    ENV['AWS_S3_BUCKET_NAME']
  end
end
