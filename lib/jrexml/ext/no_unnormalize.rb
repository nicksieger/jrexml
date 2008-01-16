require 'rexml/text'
require 'jrexml/ext/base_parser'

module REXML
  class Text
    alias_method :original_initialize, :initialize

    # Redefine text initialize to receive the expanded value, since this is done
    # by JREXML.
    #
    # Original arity/args is:
    # def initialize arg, respect_whitespace=false, parent=nil, raw=nil, entity_filter=nil, illegal=ILLEGAL
    def initialize(value, *args)
      # Text.new is always called with raw = true from treeparser.rb
      if !REXML::Parsers::BaseParser.default_parser && args[2]
        args[2] = nil
        original_initialize(value, *args)
        # Set the 'unnormalized' ivar up front, since it's already expanded
        @unnormalized = value
      else
        original_initialize(value, *args)
      end
    end
  end
end
