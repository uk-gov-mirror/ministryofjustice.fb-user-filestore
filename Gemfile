source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'rails', '~> 5.2.2'
gem 'puma', '~> 4.0'
gem 'aws-sdk-s3', '~> 1'
gem 'jwt'
gem 'sentry-raven'
gem 'tzinfo-data'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'dotenv-rails'
end

group :test do
  gem 'timecop'
end

group :development do
   gem 'guard-rspec', require: false
end
