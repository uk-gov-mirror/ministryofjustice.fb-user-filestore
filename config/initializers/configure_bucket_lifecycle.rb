# Not possible until correct permission applied to credentials
#
# if ENV['AWS_ACCESS_KEY_ID'] &&
#    ENV['AWS_SECRET_ACCESS_KEY'] &&
#    ENV['AWS_REGION'] &&
#    ENV['AWS_S3_BUCKET_NAME']
#   client = Aws::S3::Client.new
#
#   client.put_bucket_lifecycle_configuration({
#     bucket: ENV['AWS_S3_BUCKET_NAME'],
#     lifecycle_configuration: {
#       rules: [{
#         expiration: { days: 29 },
#         id: '28d',
#         filter: { prefix: '28d/' },
#         status: 'Enabled',
#         abort_incomplete_multipart_upload: {
#           days_after_initiation: 29 }
#         }
#       ]
#     }
#   })
# end
