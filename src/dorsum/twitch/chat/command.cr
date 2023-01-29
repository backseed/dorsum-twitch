require "./trigger"

module Dorsum
  module Twitch
    module Chat
      # Command (eg. !title) with an associated reply or action.
      class Command < Trigger
        # The name of the command, without the ! prefix.
        property trigger : String

        def initialize
          super

          @trigger = ""
        end

        def label : String
          @trigger
        end

        def ===(other)
          return false unless other.is_a?(Command)

          id == other.id || trigger == other.trigger
        end

        def <=>(other)
          return -1 unless other.is_a?(Trigger)

          label <=> other.label
        end
      end
    end
  end
end
