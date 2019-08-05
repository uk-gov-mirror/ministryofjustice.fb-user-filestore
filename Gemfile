source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').chomp

gem 'aws-sdk-s3', '~> 1'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'jwt'
gem 'puma', '~> 4.0'
gem 'rails', '~> 5.2.3'
gem 'sentry-raven'
gem 'tzinfo-data'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 3.8'
end

group :test do
  gem 'timecop'
end

group :development do
   gem 'guard-rspec', require: false
end
