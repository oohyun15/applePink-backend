## Capfile

# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Slack Bot
require 'slackistrano/capistrano'
require_relative 'lib/custom_messaging'

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
# For documentation on these, see for example:

## Capistrano ↔ RVM 구동
require "capistrano/rvm"

## bundler 이슈
set :rbenv_type, :user
set :rbenv_ruby, '2.7.6'

## Capistrano ↔ Bundler
## * bundler require가 없으면 배포 후 자동으로 Gem 설치가 안된다.
require "capistrano/bundler"

## Capistrano ↔ assets
## *rails/assets require가 없으면 배포 후 자동으로 assets precompile이 안된다.
require "capistrano/rails/assets"

## Capistrano ↔ rpush
## * 앱 알람 기능
# require 'capistrano/rpush'
# install_plugin Capistrano::Rpush

## Capistrano ↔ migrations
## * rails/migrations require가 없으면 배포 후 자동으로 DB Migrate가 안된다.
require "capistrano/rails/migrations"

## Capistrano ↔ Bundler
## * passenger require가 없으면 배포 후 Nginx Restart가 안된다.
require "capistrano/passenger"

## Capistrano ↔ figaro
## * figaro_yml require가 없으면 application.yml 파일이 Remote 서버에 업로드가 안된다.
require "capistrano/figaro_yml"

## Capistrano ↔ database
## * database_yml require가 없으면 database.yml 파일이 Remote 서버에 업로드가 안된다.
require 'capistrano/database_yml'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }