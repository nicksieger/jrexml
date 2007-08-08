require File.dirname(__FILE__) + '/spec_helper'

describe JREXML::JavaPullParser do
  def parse(source)
    @parser = REXML::Parsers::BaseParser.new(source)
    @parser.extend(JREXML::JavaPullParser)
    @parser.stream = source
    (class << @parser; self; end).send :define_method, "base_events" do
      events = []
      baseparser = REXML::Parsers::BaseParser.new(source)
      loop do
        event = baseparser.pull
        events << event
        break if event.first == :end_document
      end
      events
    end
    @parser
  end

  def verify_events
    @parser.base_events.each do |evt|
      @parser.pull.should == evt
    end
    @parser.should be_empty
  end

  def parse_and_verify(source)
    parse source
    verify_events
  end

  it "should parse a document consisting of a single empty element" do
    parse_and_verify %q(<document/>)
  end

  it "should allow calling empty? or has_next? in between pulls" do
    @parser = parse %q(<document/>)
    @parser.pull.should == [:start_element, "document", {}]
    @parser.should_not be_empty
    @parser.pull.should == [:end_element, "document"]
    @parser.has_next?.should == true
    @parser.pull.should == [:end_document]
    @parser.has_next?.should == false
    @parser.should be_empty
  end

  it "should parse text between elements" do
    parse_and_verify %q(<document>This is the body</document>)
  end

  it "should parse multiple texts" do
    parse_and_verify <<-XML
<document>
  some text
  <a-tag/>
  some other text
</document>
XML
  end

  it "should parse attributes" do
    parse_and_verify %q(<document attr1="value" attr2='value2'/>)
  end

  it "should handle namespaces in the same way as the base parser (which is to be ignorant of them)" do
    parse_and_verify %q(<d:document xmlns:d="urn:example.com" d:attr="value"/>)
  end

  it "should handle the xml processing instruction" do
    parse_and_verify <<-XML
<?xml version="1.0" encoding="utf-8"?>
<document/>
XML
  end

  it "should handle CDATA" do
    parse_and_verify %q(<document><![CDATA[some cdata]]></document>)
  end

  it "should handle comments" do
    parse_and_verify %q(<document><!-- some comment --></document>)
  end

  it "should handle processing instructions" do
    parse_and_verify %q(<?xml version="1.0"?>
<?xml-stylesheet href="hello-page-html.xsl" type="text/xsl"?><document/>)
  end

  it "should handle simple entity refs" do
    parse_and_verify %q(<document>text &lt; other &gt;&#x20;text</document>)
  end

  it "should handle a longer, more complex document (50+K atom feed)" do
    File.open(File.dirname(__FILE__) + "/atom_feed.xml") do |f|
      parse_and_verify f.read
    end
  end

  it "should handle a REXML::Source argument" do
    parse_and_verify REXML::SourceFactory.create_from("<document/>")
  end
end
