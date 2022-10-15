require "../../../spec_helper"

describe Dorsum::Twitch::Api::Authentication do
  it "generates a URL used to request an access token" do
    config = Dorsum::Config.new
    config.client_id = "2NPWzpWBESxop8gW"
    config.client_secret = "2emyJyFj33S9Pf8Z"

    authentication = Dorsum::Twitch::Api::Authentication.new(config)
    authentication.url.should eq(
      "https://id.twitch.tv/oauth2/token" \
      "?client_id=2NPWzpWBESxop8gW&client_secret=2emyJyFj33S9Pf8Z&grant_type=client_credentials"
    )
  end

  it "returns an access token after server returns a successful response" do
    WebMock.stub(:post, %r{\Ahttps://id.twitch.tv/oauth2/token}).to_return(
      status: 200,
      body: {
        "access_token" => "xxxx",
        "expires_in"   => 3600,
      }.to_json
    )

    config = Dorsum::Config.new
    config.client_id = "2NPWzpWBESxop8gW"
    config.client_secret = "2emyJyFj33S9Pf8Z"

    authentication = Dorsum::Twitch::Api::Authentication.new(config)
    authentication.perform.should eq(true)

    authentication.access_token.should eq("xxxx")
    authentication.expires_in.should eq(3600)
    authentication.error.should be_nil

    authentication.expired?.should be_false
  end

  it "returns an error description after server returns a failed response" do
    WebMock.stub(:post, %r{\Ahttps://id.twitch.tv/oauth2/token}).to_return(
      status: 500,
      body: "Something went wrong."
    )

    config = Dorsum::Config.new
    config.client_id = "2NPWzpWBESxop8gW"
    config.client_secret = "2emyJyFj33S9Pf8Z"

    authentication = Dorsum::Twitch::Api::Authentication.new(config)
    authentication.perform.should eq(false)

    authentication.access_token.should be_nil
    authentication.expires_in.should be_nil
    authentication.error.should eq("Something went wrong.")

    authentication.expired?.should be_false
  end

  it "is expired when it's passed the expires_at time" do
    authentication = Dorsum::Twitch::Api::Authentication.new(Dorsum::Config.new)
    authentication.expired?.should be_false

    authentication.expires_at = Time.monotonic + Time::Span.new(seconds: 30)
    authentication.expired?.should be_false

    authentication.expires_at = Time.monotonic - Time::Span.new(seconds: 30)
    authentication.expired?.should be_true
  end
end
