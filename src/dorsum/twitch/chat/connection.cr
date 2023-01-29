module Dorsum
  module Twitch
    module Chat
      abstract class Connection
        abstract def gets
        abstract def puts(data : String)
      end
    end
  end
end
