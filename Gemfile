source 'http://rubygems.org'

gem "bcrypt-ruby", "~> 2.1.4"

gem 'sinatra', '1.2.6'
gem "thor"

gem 'ruby-mysql', "2.9.3"
group :production do
  gem "pg"
end
#gem "resque"
gem "redis"

gem "rails_config"

gem "json"
# Use unicorn as the web server
gem 'unicorn'

gem "remote_syslog_logger"

# keep running server up to date
gem "shotgun", :group => :development

gem 'ruby-debug19', :require => 'ruby-debug'

gem 'nokogiri'

# deploy
gem "capistrano", :group => [:development, :test]