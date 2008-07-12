$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)
require 'rubygems'
require 'spec'
require 'spec/interop/test'

require 'active_support'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'

require 'rspec-rails/rspec-rails'
require 'date_time_text_field_helpers'

Spec::Runner.configure do |config|
  config.include Spec::Rails::Matchers
end
