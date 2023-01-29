require "./trigger"

module Dorsum
  module Twitch
    module Chat
      # Expression (eg. discord) with an associated reply or action.
      class Detect < Trigger
        # Expression that triggers the command.
        property trigger : Regex

        def initialize
          super

          @trigger = Regexp.new
        end

        def label : String
          @trigger
        end

        def ===(other)
          return false unless other.is_a?(Detect)

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
