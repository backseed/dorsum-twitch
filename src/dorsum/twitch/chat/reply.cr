module Dorsum
  module Twitch
    module Chat
      # Formats a reply by completing a reply template using the current chat context.
      class Reply
        property template : String
        property message : Message

        def initialize(@template, @message)
        end

        def to_s
          @template
        end
      end
    end
  end
end

