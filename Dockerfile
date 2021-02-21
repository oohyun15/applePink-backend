# Base image for our Ruby on Rails application
FROM ruby:2.6.5

# Set directory name as environmental variable
ENV APP_HOME /applePink

# Installation of dependencies
RUN apt-get update -qq \
  && apt-get install -y \
      # Needed for certain gems
    build-essential \
         # Needed for postgres gem
    libpq-dev \
    nodejs \
    postgresql-client \
    # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt \
    /var/lib/dpkg \
    /var/lib/cache \
    /var/lib/log

# Create a directory for our application and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add our Gemfile & Gemfile.lock and install gems
ADD Gemfile* $APP_HOME/
RUN gem install bundler:2.1.4
RUN bundle install

# Copy over our application code
COPY . $APP_HOME

# This script runs every time the container is created, necessary for rails
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Set Rails to run in production
#ENV RAILS_ENV production 
#ENV RACK_ENV production
