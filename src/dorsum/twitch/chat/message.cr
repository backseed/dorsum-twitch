module Dorsum
  module Twitch
    module Chat
      class Message
        class InvalidMessage < Exception; end

        getter text : String

        getter annotations : String?
        getter source : String?
        getter command : String?
        getter arguments : String?
        getter message : String?
        @parsed_annotations : Hash(String, String)

        ANNOTATIONS = "(@(?<annotations>[^[:space:]]+) )"
        SOURCE      = "((?<source>[^[:space:]]+) )"
        COMMAND     = "(?<command>[A-Z]+|\\d{3})"
        ARGUMENT    = "(?:[^: ][^ ]*)"
        ARGUMENTS   = "(?: (?<arguments>#{ARGUMENT}(?: #{ARGUMENT})*))"
        MESSAGE     = "(?: \\:(?<message>.+)?)"

        def initialize(@text)
          match = text.strip.match(/\A#{ANNOTATIONS}?#{SOURCE}?#{COMMAND}#{ARGUMENTS}?#{MESSAGE}?/)
          raise InvalidMessage.new "Message #{@text} is invalid." if match.nil?

          groups = match.to_h
          @annotations = groups["annotations"]
          @source = groups["source"]
          @command = groups["command"]
          @arguments = groups["arguments"]
          @message = groups["message"]
          @parsed_annotations = parse_annotations
        end

        def channel
          return unless arguments

          arguments.as(String)[1..]
        end

        def parsed_annotations
          @parsed_annotations ||= parse_annotations
        end

        def display_name
          parsed_annotations["display-name"]
        end

        def color
          parsed_annotations["color"]
        end

        delegate ansi_code, to: ansi_color

        def ansi_color
          AnsiColor.new(color)
        end

        def user_id
          parsed_annotations["user-id"]
        end

        def badges
          parsed_annotations["badges"].split(",")
        end

        def badge
          if any_badge?("broadcaster")
            "⧱"
          elsif any_badge?("moderator")
            "◆"
          elsif any_badge?("subscriber")
            "◇"
          else
            " "
          end
        end

        def ban_duration
          parsed_annotations["ban-duration"]
        end

        def tmi_sent_ts
          parsed_annotations["tmi-sent-ts"]
        end

        def sent_at
          return unless parsed_annotations["tmi-sent-ts"]

          Time.unix_ms(parsed_annotations["tmi-sent-ts"].to_i64)
        end

        def formatted_ban_duration
          self.class.formatted_time_span(Time::Span.new(seconds: ban_duration.to_i))
        rescue KeyError
          "permanent"
        end

        def write_to_log
          Log.info { "\e[38;5;#{ansi_code}m#{badge} #{display_name}:\e[0m #{message}" }
        end

        def self.formatted_time_span(span)
          formatted = ""
          span = Time::Span.new(seconds: span.to_i)
          formatted += "#{span.hours}h" if span.hours > 0
          formatted += "#{span.minutes}m" if span.minutes > 0
          formatted += "#{span.seconds}s" if span.seconds > 0
          formatted
        end

        private def any_badge?(badge : String)
          badges.any? { |item| item.starts_with?(badge) }
        end

        private def parse_annotations
          parsed = {} of String => String
          unless @annotations.nil?
            @annotations.as(String).split(";").each do |item|
              name, value = item.split("=", 2)
              parsed[name] = value
            end
          end
          parsed
        end
      end
    end
  end
end
