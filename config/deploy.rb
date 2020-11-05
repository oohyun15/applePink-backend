## config/deploy.rb

# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

## [나의 Rails 프로젝트 이름] 변수 설정
set :application, "applePink-backend"
# [Example] set :application, "test4674"

## [Rails 프로젝트가 저장된 Github] 변수 설정
set :repo_url, "git@github.com:oohyun15/applePink-backend.git"
# [Example] git@github.com:kbs4674/cicd_test2.git

## Github(:repo_url)부터 프로젝트를 가져올 branch
set :branch, :master

## 배포 환경변수 설정
set :use_sudo, false
set :deploy_via, :remote_cache

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

## Github에 Push되면 안되는 중요한 파일에 있어선 해당 리스트에 추가하는게 좋음.
set :linked_files, %w{config/application.yml config/database.yml config/master.key}

## 프로젝트 배포 후 유지에 있어 공통으로 쓰이는 폴더들
# Capistrano에 배포된 프로젝트는 현재 상용서비스로 사용되는 프로젝트와 과거에 배포되었던 프로젝트 총 :keep_releases개 로 나뉘어 관리가 이루어진다.
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle')



# Capistrano를 통해 배포된 현재/과거에 배포됐던 프로젝트 최대 수용갯수 (Default : 5)
set :keep_releases, 5

# set :rvm_ruby_version, 'ruby-2.6.5'
# set :rvm_type, :user
# set :passenger_restart_with_touch, true
# set :rvm_bin_path, `which rvm`

## [Rails Version 5.2 ~] master.key 파일을 EC2 서버로 Upload
namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app), in: :sequence, wait: 10 do
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
      end
    end
  end
end

set :default_env, {
  PATH: '$HOME/.npm-packages/bin/:$PATH',
  NODE_ENVIRONMENT: 'production'
}

set :delayed_job_server_role, :worker
set :delayed_job_args, "-n 2"

# before 'deploy:publishing', 'deploy:stop'
after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  task :restart do
    invoke 'delayed_job:restart'
    invoke 'rpush:restart'
  end
end