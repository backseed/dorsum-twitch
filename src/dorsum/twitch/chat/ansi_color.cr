module Dorsum
  module Twitch
    module Chat
      class AnsiColor
        getter color : String?
        getter ansi_code : UInt8

        def initialize(@color)
          if @color.nil? || @color == ""
            @ansi_code = 231_u8
          else
            color = @color.as(String)
            @ansi_code = normalize(
              color[1, 2].to_i(16),
              color[3, 2].to_i(16),
              color[5, 2].to_i(16)
            )
          end
        end

        REACH = 255.0 / 5.0

        private def normalize(r : Int32, g : Int32, b : Int32)
          code = 16 + 36 * (r / REACH).round + 6 * (g / REACH).round + (b / REACH).round
          UInt8.new(code)
        end
      end
    end
  end
end
