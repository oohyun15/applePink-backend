<p align="center"><a href="https://www.applepink.ml" target="_blank" rel="noopener noreferrer"><img width="150" src="https://raw.githubusercontent.com/oohyun15/applePink-backend/master/public/image/default.png" alt="apple-pink"></a></p>

<h1 align="center">모두나눔</h1>
<p align="center">
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Foohyun15%2FapplePink-backend&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/></a>
<a href="https://circleci.com/gh/oohyun15/applePink-backend/tree/master"><img src="https://circleci.com/gh/oohyun15/applePink-backend/tree/master.svg?style=shield"></a>
</p>
<h3 align="center">Location-Based C2C Shared Platform</h3>
<p align="center">
  <a href="https://www.applepink.ml" target="_blank">Learn more</a>
</p>

## Collaborator

| [<img src="https://avatars2.githubusercontent.com/u/52606560?s=400&u=2a492fa6991fe8fe79db9e5bc6442131ab4d5259&v=4" width="200">](https://github.com/oohyun15) <br> oohyun15| [<img src="https://avatars2.githubusercontent.com/u/52434222?s=400&v=4" width="200">](https://github.com/MaSungHo) <br> MaSungHo | 
| :-----------------------------------: | :---------------------------------------: |

## Intro
This repository is Modunanum's Back-end API server built with **Ruby on Rails**.
  
You can find our [FE repository](https://github.com/d-virusss/capstone_front_RN) built with **React Native**.

This README would normally document whatever steps are necessary to get the
application up and running.  
  
Latest update: **2021.06.06**

## Requirements 
* Linux Ubuntu 16.04+
* ruby 2.6.5p114
* Rails 6.0.0
* Bundler 2.1.4
* PostgreSQL 9.5.23+
* ImageMagick 7.0.10+
* Xcode 12.0+
* Jenkins 2.263.3 *(optional)*
* Capistrano 3.14.1 *(optional)*

#### 3rd-party API
* [Kakao Developer](https://developers.kakao.com/)
* [Apple Developer](https://developer.apple.com/)
* [Firebase](https://firebase.google.com/)
* [Amazon Web Service](https://aws.amazon.com/)
* [Sendgrid](https://sendgrid.com/)
* [Cafe24](https://hosting.cafe24.com/)
* [Kakaocert](https://www.kakaocert.com/)
* [Cloudmersive](https://cloudmersive.com/)
* [Sentry](https://sentry.io/)
* [CircleCI](https://circleci.com/)

## Features
#### OAuth Social Sign-in
* Kakao
* Apple

#### Regional Certification
* Google Maps
* Kakao Maps (for converting GPS coordinates to a legal county)
  * Currently support Suwon only (57 counties)

#### Product Posting
* to provide/request

#### 1:1 Chatting
* Firebase realtime database

#### Keyword Notification
* Up to 20 registered
* FCM (Android & Apple)

#### Electronic Signature
* Kakaocert

#### Email & SMS Notification
* Sendgrid (Email)
* Cafe24 (SMS)

#### Association Certification
* University
  * Support 139 universities in Korea
* Company
  * Support 25 companies in Korea

#### Converting from HEIC to PNG 
* Cloudmersive

#### Administrator Page
* Activeadmin

#### Continuous Integration & Continuous Delivery
* Jenkins
* CircleCI
* Capistrano
* Sentry

## Getting started
**1. Create application.yml & database.yml**

```zsh
# install Gemfile
bundle install

# create application.yml
figaro install

# create database.yml
touch config/database.yml
```

**2. Set secret key**  

```zsh # grant new secret key
bundle exec rake secret

```

**3. Set application.yml**  
Copy below scripts and fill in the values.
```yml
# config/application.yml

DB_NAME: 
SECRET_KEY_BASE: # bundle exec rake secret

# Activeadmin
ACTIVEADMIN_EMAIL: 
ACTIVEADMIN_PASSWD: 

# seed
TEST_EMAIL_FRONT: 
TEST_EMAIL_BACK: 
TEST_PASSWORD: 

# KAKAO REST_API
KAKAO_CLIENT_ID: 

# Sendgrid API
SENDGRID_API_KEY: 

# FCM Server key
FCM_SERVER_KEY: 

# Kakaocert
KAKAO_CERT_LINK_ID: 
KAKAO_CERT_SERCRET_KEY: 
KAKAO_CERT_CLIENT_CODE: 
KAKAO_CERT_SUB_CLIENT_ID: 
KAKAO_CERT_CALL_CERNTER_NUM: 

# Cloudmersive
CLOUDMERSIVE_API_KEY: 

# Apple sign-in
APPLE_CLIENT_ID: 
APPLE_TEAM_ID: 
APPLE_KEY: 
APPLE_PEM: 
APPLE_REDIRECT_URI: 

# Cafe24Sms
SMS_SECURE: 
SMS_USER_ID: 
SMS_SPHONE1: 
SMS_SPHONE2: 
SMS_SPHONE3: 

# setnry
SENTRY_DSN: 

production:
  SERVER_DB_USER_NAME: 
  SERVER_DB_USER_PASSWD: 
  
  #AWS S3
  AWS_ACCESS_KEY_ID: 
  AWS_SECRET_ACCESS_KEY: 

development:
  LOCAL_DB_USER_NAME: 
  LOCAL_DB_USER_PASSWD: 

```

**4. Set database.yml**
```yml
# config/database.yml

default: &default
  adapter: postgresql
  host: localhost
  encoding: utf8
  username: <%= ENV["LOCAL_DB_USER_NAME"] %>
  password: <%= ENV["LOCAL_DB_USER_PASSWD"] %>
  pool: 5

development:
  <<: *default
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>

production:
  adapter: postgresql
  host: localhost
  encoding: utf8
  username: <%= ENV["SERVER_DB_USER_NAME"] %>
  password: <%= ENV["SERVER_DB_USER_PASSWD"] %>
  pool: 5
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>
  
```

**5. Run local server**

```zsh
# DB setup
rake db:create
rake db:migrate
rake db:seed

# Start local server
rails s         // localhost:3000
rails s -p 8081 // localhost:8081

```

You can access [localhost:3000](http://localhost:3000) to check the server.

## How to deploy
I will not explain in detail in this part.  
If you were in trouble, please contact us.

```zsh
cap install // you have to edit files: Capfile, production.rb deploy.rb
cap production setup
cap production deploy

```
