require "log"
require "redis"

module Dorsum
  module Twitch
    class Cli
      # Stores the context of the latest invocation of the command-line interface.
      getter context : Context
      # Manages the persistent configuration of the service on disk.
      getter config : Config
      # Connection to the Redis server.
      getter redis : Redis::PooledClient

      def initialize
        @context = Context.new
        @config = Config.load
        @redis = Redis::PooledClient.new
      end

      def run(argv)
        OptionParser.parse(argv, context, config)
        if context.errors.any?
          print_errors
        elsif context.run?
          run_command
        end
      end

      def run_command
        case context.command
        when "config"
          config.save
        else
          run_forever
        end
      end

      private def run_forever
        Log.info { "Starting dorsum-twitch" }
        loop { run }
      end

      private def run
        Dorsum::Twitch::Chat::Session.new(config, context, redis).run
      end

      private def print_errors
        context.errors.each do |error|
          Log.fatal { error }
        end
      end
    end
  end
end
