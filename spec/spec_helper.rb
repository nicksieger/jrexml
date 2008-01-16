$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'jrexml/java_pull_parser'
require 'jrexml/ext/base_parser'

Spec::Runner.configure do |config|
  config.before :all do
  end
end
