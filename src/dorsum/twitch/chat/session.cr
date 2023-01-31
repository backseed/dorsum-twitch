require "log"
require "redis"

module Dorsum
  module Twitch
    module Chat
      class Session
        property config : Dorsum::Config
        property context : Dorsum::Context
        property client : Dorsum::Twitch::Chat::Client
        property api : Dorsum::Twitch::Api::Client
        property redis : Redis::PooledClient

        def initialize(@config, @context, @redis)
          @client = Dorsum::Twitch::Chat::Client.new
          @api = Dorsum::Twitch::Api::Client.new(@config)
          @roll_call = RollCall.new(@redis)
        end

        def run
          if context.channel.empty?
            Log.fatal { "Please specify a channel name with --channel" }
            exit -1
          end

          api.authenticate
          client.connect
          send_authentication
          loop do
            api.authenticate if api.authentication.expired?
            handle_message(get_message)
          end
        end

        def get_message : Dorsum::Twitch::Chat::Message
          loop do
            begin
              line = client.gets
              return Dorsum::Twitch::Chat::Message.new(line) if line
            rescue e : IO::TimeoutError
              Log.debug { "T: #{e.message}" }
            end
          end
        end

        def handle_message(message : Dorsum::Twitch::Chat::Message)
          case message.command
          when "001"
            send_capabilites
            send_join_channel
          when /\A\d{3}\Z/
          when "CAP"
          when "CLEARCHAT"
            if message.message == config.username
              Log.info { "Exiting because we were timed out." }
              exit
            end
          when "JOIN"
            if message.source && message.source.as(String).starts_with?(":#{config.username}!")
              Log.info { "Joined #{message.arguments}!" }
            end
          when "NOTICE"
            Log.info { message.message }
          when "PART"
          when "PING"
            client.puts("PONG #{message.message}")
          when "PONG"
          when "PRIVMSG"
            message.write_to_log
            @roll_call.record(message)
          when "RECONNECT"
            Log.warn { "Server asked us to reconnect" }
            return
          when "ROOMSTATE"
          when "USERSTATE"
          when "USERNOTICE"
            message.write_to_log
            @roll_call.record(message)
          else
            Log.info { "Not implemented: #{message.command}" }
          end
        end

        def send_authentication
          Log.info { "Sending password and username to server…" }
          client.puts("PASS #{config.password}")
          client.puts("NICK #{config.username}")
        end

        def send_capabilites
          Log.info { "Registering capabilites with the server…" }
          # We don't care about JOIN and PART messages.
          # client.puts("CAP REQ :twitch.tv/membership")
          client.puts("CAP REQ :twitch.tv/tags")
          client.puts("CAP REQ :twitch.tv/commands")
        end

        def send_join_channel
          Log.info { "Joining ##{context.channel}…" }
          client.puts("JOIN ##{context.channel}")
        end
      end
    end
  end
end
