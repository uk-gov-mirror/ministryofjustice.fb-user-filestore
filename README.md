# fb-user-filestore
[![Build Status](https://travis-ci.org/ministryofjustice/fb-user-filestore.svg?branch=master)](https://travis-ci.org/ministryofjustice/fb-user-filestore)

## Environment Variables

Form Builder API service that allows files to be stored and retrieved. This
Rails app is an internal API to handle file storage with AWS S3

The following environment variables are required for this application to work
correctly.

- `SERVICE_TOKEN_CACHE_ROOT_URL` - http/https of location of service token cache Rails application
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `AWS_S3_BUCKET_NAME` - Bucket name to upload to and download from
