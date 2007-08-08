$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'rexml/parsers/baseparser'
require 'jrexml'

Spec::Runner.configure do |config|
  config.before :all do
  end
end
