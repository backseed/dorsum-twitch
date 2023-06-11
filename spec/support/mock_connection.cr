module Support
  class MockConnection < Dorsum::Twitch::Chat::Connection
    property responses : Array(String)
    property written : Array(String)

    def initialize
      @responses = [] of String
      @written = [] of String
      @connected = false
      @stalled = false
    end

    def gets : String
      verify_connected
      @responses.shift
    end

    def puts(data : String)
      verify_connected
      @written << data
    end

    def connect
      @connected = true
    end

    def close
      @connected = false
    end

    private def verify_connected
      raise "Client is not connected, please call #connect." unless @connected
    end
  end
end
