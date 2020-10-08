# applePink-backend

**Collaborator**

| [<img src="https://avatars2.githubusercontent.com/u/52606560?s=400&u=2a492fa6991fe8fe79db9e5bc6442131ab4d5259&v=4" width="200">](https://github.com/oohyun15) <br> oohyun15| [<img src="https://avatars2.githubusercontent.com/u/52434222?s=400&v=4" width="200">](https://github.com/MaSungHo) <br> MaSungHo | 
| :-----------------------------------: | :---------------------------------------: |

## Intro
This repository is Modunanum's Back-end API server built with **Ruby on Rails**.
  
You can find our [Front-end repo](https://github.com/d-virusss/capstone_front_RN) built with **React Native**.

This README would normally document whatever steps are necessary to get the
application up and running.

## Version
* Ruby version  
**ruby 2.6.5p114**

* Ruby on Rails version  
**Rails 6.0.0**

* Bundler version  
**Bundler 2.1.4**

* Database  
**PostgreSQL 9.5.23**  

* Deployment instructions(optional)  
**capistrano 3.14.1**


## How to run
**1. Create applcation.yml & database.yml**

```zsh
# install Gemfile
bundle install

# create application.yml
figaro install

# create database.yml
touch config/database.yml
```

**2. Set application.yml**
```yml
# config/application.yml

DB_NAME: "YOUR_DB_NAME"
DB_USER_NAME: "YOUR_LOCAL_NAME"
DB_USER_PASSWD: "YOUR_PASSWORD"

```

**3. Set database.yml**
```yml
# config/database.yml

default: &default
  adapter: postgresql
  host: localhost
  encoding: utf8
  username: <%= ENV["DB_USER_NAME"] %>
  password: <%= ENV["DB_USER_PASSWD"] %>
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

# IF YOU WANT TO DEPLOY, YOU MUST KNOW PUBLIC KEY TO ACCESS AWS EC2 SERVER.
# It is recommended not to add this part unless it is a special case.
production:
  <<: *default
  database: <%= ENV["DB_NAME"] %>_<%= Rails.env %>
  
```

**4. run local server**

```zsh
# DB setup
rake db:create
rake db:migrate
rake db:seed    // optional

# Start local server
rails s         // localhost:3000
rails s -p 8081 // localhost:8081

```

## How to deploy
I will not explain in detail in this part.  
If you were in trouble, please contact us.

```zsh
cap install   // you have to edit files: Capfile, production.rb deploy.rb
cap production setup
cap production deploy

```
