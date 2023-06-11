require "log"
require "redis"

module Dorsum
  module Twitch
    module Chat
      class Session
        property config : Dorsum::Config
        property context : Dorsum::Context
        property connection : Dorsum::Twitch::Chat::Connection
        property redis : Redis::PooledClient
        property api : Dorsum::Twitch::Api::Client

        def initialize(@config, @context, @connection, @redis)
          @api = Dorsum::Twitch::Api::Client.new(@config)
          @roll_call = RollCall.new(@redis)
          @authenticated = false
        end

        def run
          if context.channel.empty?
            Log.fatal { "Please specify a channel name with --channel" }
            return
          end

          api.authenticate
          connection.connect
          send_authentication
          loop do
            api.authenticate if api.authentication.expired?
            handle_message(get_message)
          end
        end

        def get_message : Dorsum::Twitch::Chat::Message
          loop do
            begin
              line = connection.gets
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
              raise Dorsum::ReconnectError.new
            end
          when "JOIN"
            if message.source && message.source.as(String).starts_with?(":#{config.username}!")
              Log.info { "Joined #{message.arguments}!" }
            end
          when "NOTICE"
            Log.info { message.message }
          when "PART"
          when "PING"
            connection.puts("PONG #{message.message}")
          when "PONG"
          when "PRIVMSG"
            message.write_to_log
            @roll_call.record(message)
          when "RECONNECT"
            Log.warn { "Server asked us to reconnect" }
            exit -1
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
          connection.puts("PASS #{config.password}")
          connection.puts("NICK #{config.username}")
        end

        def send_capabilites
          Log.info { "Registering capabilites with the server…" }
          # We don't care about JOIN and PART messages.
          # connection.puts("CAP REQ :twitch.tv/membership")
          connection.puts("CAP REQ :twitch.tv/tags")
          connection.puts("CAP REQ :twitch.tv/commands")
        end

        def send_join_channel
          Log.info { "Joining ##{context.channel}…" }
          connection.puts("JOIN ##{context.channel}")
        end
      end
    end
  end
end
