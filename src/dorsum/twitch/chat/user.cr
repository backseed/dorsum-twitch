require "json"

module Dorsum
  module Twitch
    module Chat
      struct User
        include JSON::Serializable
        property user_id : Int64
        property display_name : String
        property color : String
      end
    end
  end
end
