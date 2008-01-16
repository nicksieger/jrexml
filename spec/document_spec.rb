require File.dirname(__FILE__) + '/spec_helper'
require 'rexml/document'

describe JREXML do
  def document
    REXML::Document.new %q(<document>text &lt; other &gt;&#x20;text</document>)
  end

  it "should not need REXML's unnormalize method" do
    REXML::Parsers::BaseParser.default_parser = true
    document.root.text.should == %q(text < other > text)

    require 'jrexml/ext/no_unnormalize'
    REXML::Parsers::BaseParser.default_parser = false
    document.root.text.should == %q(text < other > text)
  end
end
