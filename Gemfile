source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"

gem "rails", "6.0.0"
gem "rails-i18n"
gem "activesupport"
gem "pg", ">= 0.18", "< 2.0"
gem "puma", "~> 3.11"
gem "sass-rails", "~> 5"

gem "ransack"
gem "carrierwave"
gem "mini_magick"
gem "fog-aws"
gem "pry"
gem "pry-rails"

gem "devise"
gem "activeadmin"
gem "active_skin"
gem "activeadmin_addons"
gem "acts_as_list"
gem "activeadmin_reorderable"
gem "array_enum"
gem 'bcrypt' 
gem 'cloudmersive-convert-api-client'

# hashtag
gem "acts-as-taggable-on", "~> 6.0"

gem 'active_model_serializers'

# 결제 관련
gem "iamport"
gem "activerecord-import"

# job scheduling
gem "delayed_job_active_record"

gem "jbuilder", "~> 2.7"
gem "bootsnap", ">= 1.4.2", require: false

# JWT 인증
gem "jwt"
gem "figaro"

# 이메일
gem 'sendgrid-actionmailer'

# omniauth
gem 'omniauth'
gem 'omniauth-oauth2', '<= 1.3.1'
# gem 'omniauth-kakao'
gem 'omniauth-kakao', :git => 'git://github.com/insomenia/omniauth-kakao'
gem 'omniauth-apple'

# fcm
gem 'fcm'

# kakao-cert
gem 'kakaocert'

# sentry
gem "sentry-ruby"
gem "sentry-rails"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec_junit_formatter'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
end

group :test, :development do
  gem 'rspec-rails', '~> 4.0.1'
  gem 'faker'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
end

gem 'capistrano', '3.14.1'
gem 'capistrano-rails'
gem 'capistrano-passenger', '~> 0.2.0'
gem 'capistrano-webpacker-precompile', require: false
gem 'capistrano-bundler'
gem 'capistrano-rvm'
gem 'capistrano-rails-collection'
gem 'capistrano-figaro-yml'
gem 'capistrano-database-yml'
gem 'slackistrano'
# gem 'capistrano-rpush'

gem 'daemons'