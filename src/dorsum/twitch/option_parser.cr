require "option_parser"

module Dorsum
  module Twitch
    class OptionParser
      def self.parse(argv, context : Dorsum::Context, config : Dorsum::Config)
        ::OptionParser.parse(argv) do |parser|
          parser.banner = "Usage: dorsum-twitch [options]"
          parser.separator ""
          parser.separator "Commands:"

          parser.on("config", "Update configuration and write it to disk.") do
            context.command = "config"

            parser.on("--username username", "Twitch account username") do |username|
              if username.empty?
                context.errors << "Please specify a Twitch account username."
              else
                config.username = username
              end
            end
            parser.on("--password password", "Twitch account OAuth password") do |password|
              if password.empty?
                context.errors << "Please specify a Twitch account password."
              elsif !password.starts_with?("oauth:")
                context.errors << "A Twitch account password should be an OAuth token (start with `oauth:')"
              else
                config.password = password
              end
            end
            parser.on("--client-id CLIENT-ID", "Twitch application client ID") do |client_id|
              if client_id.empty?
                context.errors << "Please specify a Twitch application client ID."
              else
                config.client_id = client_id
              end
            end
            parser.on("--client-secret CLIENT-SECRET", "Twitch application client secret") do |client_secret|
              if client_secret.empty?
                context.errors << "Please specify a Twitch application client secret."
              else
                config.client_secret = client_secret
              end
            end
          end

          parser.on("--channel CHANNEL", "Join the channel.") do |channel|
            context.channel = channel
          end

          parser.on("--verbose", "Turn on debug logging.") do
            Log.setup(:debug)
          end

          parser.on("-h", "--help", "Show this help") do
            context.run = false
            puts parser
          end
        end
      end
    end
  end
end
