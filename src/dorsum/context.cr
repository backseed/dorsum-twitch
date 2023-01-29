module Dorsum
  # Keeps the details of how the CLI tool was called.
  class Context
    property errors : Array(String)
    property triggers : Array(Dorsum::Twitch::Chat::Trigger)
    property command : String
    property? run
    property? verbose

    property channel : String

    def initialize
      @errors = [] of String
      @triggers = [] of Dorsum::Twitch::Chat::Trigger
      @command = "run"
      @run = true
      @verbose = false
      @channel = ""
    end
  end
end
