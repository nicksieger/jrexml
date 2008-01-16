require 'rexml/parsers/baseparser'

class REXML::Parsers::BaseParser #:nodoc:
  class << self
    # Set to true to disable JREXML (default nil/unset means use JREXML)
    attr_accessor :default_parser

    def new_default_parser(*args)
      prev = self.default_parser
      self.default_parser = true
      new(*args)
    ensure
      self.default_parser = prev
    end

    # Extend every REXML base parser with a version that uses a Java pull parser
    # library
    def new(*args)
      obj = allocate
      obj.extend(JREXML::JavaPullParser) unless self.default_parser
      class << obj; public :initialize; end
      obj.initialize *args
      obj
    end
  end
end
