# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  config.action_controller.session = {
    :session_key => '_Bcomposer_session',
    :secret      => '42d579235aeae7b2701d097dcf7eae0d'
  }


  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :cookie_store # :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.gem "gettext", :version => "1.93.0"
  config.gem 'mislav-will_paginate', :version => '~> 2.2.3', :lib => 'will_paginate', 
      :source => 'http://gems.github.com'
end

# Include your application configuration below

# require 'gettext/rails'
require 'RMagick'

require 'lib/bcomposer_liquid'

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings[:address] = "localhost"


# DEPRICATED AND NO LONGER SUPPORTED!!!
# *** LEAVE FALSE ***
# Special option to enable ERB bulletin templates.
# This is recommed to always be false, as it poses a huge
# security risk to the system. Liquid templates are far safer.
# ERB templates may be removed in the future.
ENABLE_ERB_LAYOUTS = false

# Don't display nor allow content pages.
# This can be used in special cases where a Bulletin has associated content
# pages that cannot be stored anywhere else.
# In effect, they just make the system more confusing but may be useful in
# some situations.
ENABLE_CONTENT_PAGES = false
