require "spec"
require "log/spec"
require "webmock"

require "../src/dorsum"
require "./support/*"

Spec.before_each do
  WebMock.reset
end

def build_dorsum_config
  config = Dorsum::Config.new
  config.client_id = "2NPWzpWBESxop8gW"
  config.client_secret = "2emyJyFj33S9Pf8Z"
  config.username = "happy-user"
  config.password = "secret"
  config
end

def build_dorsum_context
  context = Dorsum::Context.new
  context.channel = "happy-channel"
  context
end

def build_connection
  Support::MockConnection.new
end

def build_dorsum_redis
  Redis::PooledClient.new(database: 4)
end

def mock_dorsum_twitch_api_authentication_success
  WebMock.stub(:post, %r{\Ahttps://id.twitch.tv/oauth2/token}).to_return(
    status: 200,
    body: {
      "access_token" => "xxxx",
      "expires_in"   => 3600,
    }.to_json
  )
end

def build_dorsum_twitch_api_authentication
  Dorsum::Twitch::Api::Authentication.new(config)
end

def mock_dorsum_twitch_api_broadcaster_id_success
  WebMock.stub(:get, %r{\Ahttps://api.twitch.tv/helix/users}).to_return(
    status: 200,
    body: {
      "data" => [
        {"id" => "43784278"},
      ],
    }.to_json
  )
end

def mock_dorsum_twitch_api_channel_success
  WebMock.stub(:get, %r{\Ahttps://api.twitch.tv/helix/channels}).to_return(
    status: 200,
    body: {
      "data" => [
        {
          "title"     => "Having fun today 🥳",
          "game_name" => "Fortnite",
        },
      ],
    }.to_json
  )
end
