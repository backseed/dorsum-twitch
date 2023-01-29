require "uuid"

module Dorsum
  module Twitch
    module Chat
      abstract class Trigger
        # Unique identifier for the trigger.
        property id : UUID
        # False when the command may be any case (eg. !TITLE or !Title). Default is false.
        property sensitive : Bool
        # Reply to post to the channel when the trigger happens.
        property reply : String?
        # List of roles (eg. ["mod", "subscriber"]) who may use the trigger. Default is empty.
        property allow : Array(String)
        # List of preconditions to annotations for activating the trigger. Default is empty.
        property conditions : Array(String)
        # Command should not trigger a second time within the cooldown timespan.
        property cooldown : (Time::Span | Nil)

        # Returns a technical label which summarizes the full trigger.
        abstract def label : String

        def initialize
          @id = UUID.new
          @sensitive = false
          @reply = nil
          @allow = [] of String
          @conditions = [] of String
          @cooldown = nil
        end

        def matches?(message : Message)
        end

        def reply(message : Message)
          return unless @reply

          Reply.new(@reply, @message)
        end
      end
    end
  end
end
