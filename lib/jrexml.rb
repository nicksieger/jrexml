require 'rexml/parsers/baseparser'
require 'jrexml/java_pull_parser'

class REXML::Parsers::BaseParser
  # Extend every REXML base parser with a version that uses a Java pull parser 
  # library
  def self.new(*args)
    obj = allocate
    obj.extend(JREXML::JavaPullParser)
    obj.send :initialize, *args
    obj
  end
end