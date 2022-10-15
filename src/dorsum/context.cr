module Dorsum
  # Keeps the details of how the CLI tool was called.
  class Context
    property errors : Array(String)
    property command : String
    property? run
    property? verbose

    property channel : String

    def initialize
      @errors = [] of String
      @command = "run"
      @run = true
      @verbose = false
      @channel = ""
    end
  end
end
