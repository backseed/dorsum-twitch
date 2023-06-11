require "../../../spec_helper"

describe Dorsum::Twitch::Chat::Session do
  describe "starting a new session" do
    it "sends credentials, sends capabilities, and joins the channel" do
      mock_dorsum_twitch_api_authentication_success
      config = build_dorsum_config
      context = build_dorsum_context
      connection = build_connection
      connection.responses = [
        ":tmi.twitch.tv 001 #{config.username} :Welcome, GLHF!",
        ":tmi.twitch.tv 002 #{config.username} :Your host is tmi.twitch.tv",
        ":tmi.twitch.tv 003 #{config.username} :This server is rather new",
        ":tmi.twitch.tv 004 #{config.username} :-",
        ":tmi.twitch.tv 375 #{config.username} :-",
        ":tmi.twitch.tv 372 #{config.username} :You are in a maze of twisty passages, all alike.",
        ":tmi.twitch.tv 376 #{config.username} :>",
        ":tmi.twitch.tv CAP * ACK :twitch.tv/tags",
        ":tmi.twitch.tv CAP * ACK :twitch.tv/commands",
        ":#{config.username}!#{config.username}@#{config.username}.tmi.twitch.tv JOIN ##{context.channel}",
      ]

      session = Dorsum::Twitch::Chat::Session.new(
        config: config,
        context: context,
        connection: connection,
        redis: build_dorsum_redis
      )
      Log.capture do |log|
        session.run rescue IndexError
        log.check(:info, "Joining ##{context.channel}…")
        log.check(:info, "Joined ##{context.channel}!")
      end
    end
  end

  describe "connected session" do
    it "records a sub message on roll call" do
      redis = build_dorsum_redis
      redis.flushdb
      session = Dorsum::Twitch::Chat::Session.new(
        config: build_dorsum_config,
        context: build_dorsum_context,
        connection: build_connection,
        redis: redis
      )
      message = Dorsum::Twitch::Chat::Message.new(
        "@display-name=person;user-id=56789325;tmi-sent-ts=1640996246284;color=#DE9027 :tmi.twitch.tv USERNOTICE #fishing Thanks for all the fish."
      )
      session.handle_message(message)
      result = redis.command(["XRANGE", message.channel, "-", "+"])
      result.as(Array(Redis::RedisValue)).size.should eq(1)
    end
  end
end
