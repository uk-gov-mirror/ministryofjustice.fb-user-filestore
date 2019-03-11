## Environment Variables

Form Builder API service that allows files to be stored and retrieved. This
Rails app is an internal API to handle file storage with AWS S3

The following environment variables are required for this application to work
correctly.

- `SERVICE_TOKEN_CACHE_ROOT_URL` - http/https of location of service token cache Rails application
- `MAX_IAT_SKEW_SECONDS` - max time a signed JWT is allowed to deviate from time of submission
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_S3_BUCKET_NAME` - Bucket name to upload to and download from

## Making API calls

To craft calls to the API the below script can be used from the rails console.
This will hit the API with a valid request to upload a file.

```ruby
require Rails.root.join('spec/support/request_helpers.rb')

payload = json_request(Base64.encode64(File.open(Rails.root.join('spec/fixtures/files/image.png')).read)); `curl -X POST --header "x-access-token: #{JWT.encode(payload.merge(iat: Time.now.to_i), 'service-token', 'HS256')}" --header "Content-Type: application/JSON" --data '#{payload.to_json}' http://localhost:3000/service/some-service/user/some-user`
```
