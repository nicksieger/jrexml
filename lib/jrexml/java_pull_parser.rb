module JREXML
  begin
    XmlPullParser = Java::org.xmlpull.v1.XmlPullParser
  rescue
    raise LoadError, "JREXML is only for JRuby" if RUBY_PLATFORM !~ /java/
    XPP_VERSION = "1.1.4"
    begin
      require "xpp3-#{XPP_VERSION}.jar"
      @triedxpp ||= 0
      @triedxpp += 1
      retry unless @triedxpp > 1
    rescue LoadError
      raise LoadError, "Unable to load XmlPullParser java class; " +
        "you need to include xpp3-#{XPP_VERSION}.jar on the classpath"
    end
  end

  START_DOCUMENT         = XmlPullParser::START_DOCUMENT
  END_DOCUMENT           = XmlPullParser::END_DOCUMENT
  START_TAG              = XmlPullParser::START_TAG
  END_TAG                = XmlPullParser::END_TAG
  TEXT                   = XmlPullParser::TEXT
  CDSECT                 = XmlPullParser::CDSECT
  COMMENT                = XmlPullParser::COMMENT
  ENTITY_REF             = XmlPullParser::ENTITY_REF
  IGNORABLE_WHITESPACE   = XmlPullParser::IGNORABLE_WHITESPACE
  PROCESSING_INSTRUCTION = XmlPullParser::PROCESSING_INSTRUCTION
  
  ADJACENT_EVENTS = [TEXT, ENTITY_REF]

  class XmlParsingError < StandardError; end

  module JavaPullParser
    def self.factory
      @factory ||= proc do
        fact = org.xmlpull.v1.XmlPullParserFactory.newInstance
        fact.set_namespace_aware false
        fact.set_validating false
        fact
      end.call     
    end

    def stream=(source)
      @source = JavaPullParser.factory.newPullParser
      @source.setInput java.io.ByteArrayInputStream.new(get_bytes(source)), nil
    end

    # Returns true if there are no more events
    def empty?
      event_stack.empty?
    end

    # Returns true if there are more events.  Synonymous with !empty?
    def has_next?
      !empty?
    end

    # Push an event back on the head of the stream.  This method
    # has (theoretically) infinite depth.
    def unshift(event)
      @event_stack ||= []
      @event_stack.unshift event
    end

    def peek(depth = 0)
      raise "not implemented"
    end

    def pull
      event = event_stack.shift
      unless @first_event_seen
        @first_event_seen = true
        version = @source.getProperty("http://xmlpull.org/v1/doc/properties.html#xmldecl-version")
        if version
          standalone = @source.getProperty("http://xmlpull.org/v1/doc/properties.html#xmldecl-standalone")
          encoding = @source.getInputEncoding
          unshift event
          return [:xmldecl, version, encoding, standalone] 
        end
      end
      convert_event(event)
    end

    def all_events
      events = []
      while event = pull
        events << event
      end
      events
    end

    private
    def convert_event(event)
      if ADJACENT_EVENTS.include?(event)
        text = ""
        loop do
          case event
          when TEXT
            text << @source.text
          when ENTITY_REF
            text << "&#{@source.name};"
          end
          event = event_stack.shift
          break unless event
          if !ADJACENT_EVENTS.include?(event)
            unshift event
            return [:text, text]
          end
        end
      end
      convert_event_without_text_or_entityref(event)      
    end

    def convert_event_without_text_or_entityref(event)
      case event
      when START_DOCUMENT
        [:start_document]
      when END_DOCUMENT
        @document_ended = true
        [:end_document]
      when START_TAG
        attributes = {}
        0.upto(@source.attribute_count - 1) do |i|
          attributes[@source.getAttributeName(i)] = @source.getAttributeValue(i)
        end
        [:start_element, @source.name, attributes]
      when END_TAG
        [:end_element, @source.name]
      when IGNORABLE_WHITESPACE
        [:text, @source.text]
      when CDSECT
        [:cdata, @source.text]
      when COMMENT
        [:comment, @source.text]
      when PROCESSING_INSTRUCTION
        pi_info = @source.text.split(/ /, 2)
        pi_info[1] = " #{pi_info[1]}" # REXML likes the space there
        [:processing_instruction, *pi_info]
      when nil
        nil
      else
        [:unknown, debug_event(event)]
      end
    end

    def event_stack
      @event_stack ||= []
      if @event_stack.empty? && !@document_ended
        begin
          @event_stack << @source.nextToken
        rescue NativeException => e
          raise XmlParsingError, e.message
        end
      end
      @event_stack
    end

    def get_bytes(src)
      string = if src.respond_to?(:read)
        src.read
      else
        src.to_s
      end
      string.to_java_bytes
    end

    def debug_event(event)
      "XmlPullParser::#{XmlPullParser::TYPES[event]}" if event
    end
  end
end
