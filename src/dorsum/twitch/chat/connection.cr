module Dorsum
  module Twitch
    module Chat
      abstract class Connection
        abstract def gets : String | Nil
        abstract def puts(data : String)
        abstract def connect
        abstract def close
      end
    end
  end
end
