require "../../../spec_helper"

describe Dorsum::Twitch::Chat::Session do
  describe "connected session" do
    it "records a sub message on roll call" do
      redis = build_dorsum_redis
      redis.flushdb
      session = Dorsum::Twitch::Chat::Session.new(build_dorsum_config, build_dorsum_context, redis)
      message = Dorsum::Twitch::Chat::Message.new(
        "@display-name=person;user-id=56789325;tmi-sent-ts=1640996246284;color=#DE9027 :tmi.twitch.tv USERNOTICE #fishing Thanks for all the fish."
      )
      session.handle_message(message)
      result = redis.command(["XRANGE", message.channel, "-", "+"])
      result.as(Array(Redis::RedisValue)).size.should eq(1)
    end
  end
end
