require "./trigger"

module Dorsum
  module Twitch
    module Chat
      # Records a new event when a user talks for the first time during stream.
      class RollCall
        # We assume someone arrives after they haven't arrived for 8 hours.
        ARRIVE_INTERVAL = 8 * 60 * 60 * 1000

        getter redis : Redis::PooledClient

        def initialize(@redis)
        end

        def record(message : Message)
          result = @redis.set(
            "arrived:#{message.user_id}", message.tmi_sent_ts,
            nx: true, px: ARRIVE_INTERVAL
          )
          return unless result == "OK"

          @redis.command(["XADD", message.channel, "*", "arrival", to_json(message)])
        end

        private def to_json(message : Message)
          {
            "display-name" => message.display_name,
            "color"        => message.color,
            "arrived-at"   => message.tmi_sent_ts,
          }.to_json
        end
      end
    end
  end
end
