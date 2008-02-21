$: << File.dirname(__FILE__) + '/../lib' << File.dirname(__FILE__)
require 'rubygems'
require 'spec'
require 'spec/interop/test'

require 'action_controller'
require 'action_controller/test_process'
require 'action_controller/assertions/selector_assertions'
require 'action_view'

require 'rspec_on_rails/assert_select'
require 'date_time_text_field_helpers'

Spec::Runner.configure do |config|
  config.include Spec::Rails::Matchers
  config.include ActionController::Assertions::SelectorAssertions
end