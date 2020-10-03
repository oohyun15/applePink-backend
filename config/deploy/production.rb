## [Remote 서버 : 아이디] 변수 설정
# AWS EC2 Ubuntu는 기본으로 아이디는 ubuntu 이다.
set :user, 'ubuntu'
## [Example] set :user, 'ubuntu'

## REMOTE 서버 설정
set :aws_ec2_ip, "15.164.218.147"
# [Example] set :aws_ec2_ip, "52.78.236.246"

## Remote서버에 대해 배포환경 설정 (환경변수 설정)
set :rails_env, "production"
set :stage, :production

## Remote서버에서 프로젝트 배포가 이루어질 Path
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"

server fetch(:aws_ec2_ip), port: 22, roles: [:web, :app, :db], primary: true

## SSH Remote 설정 (서버 아이디 및 pem Key 경로 설정)
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w([AWS EC2 Key Pair Full Path]) }
# set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w(C:\Users\KCM\Desktop\ruby-kcm.pem) }