module Dorsum
  class TimeoutError < Exception
  end

  class ReconnectError < Exception
  end
end

require "./dorsum/*"
