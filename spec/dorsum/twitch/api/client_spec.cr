require "../../../spec_helper"

describe Dorsum::Twitch::Api::Client do
  it "authenticates to get an access token" do
    mock_dorsum_twitch_api_authentication_success

    client = Dorsum::Twitch::Api::Client.new(build_dorsum_config)
    client.authenticate.should be_true
  end

  it "returns the broadcaster id as a string when API request is successful" do
    mock_dorsum_twitch_api_authentication_success
    mock_dorsum_twitch_api_broadcaster_id_success

    client = Dorsum::Twitch::Api::Client.new(build_dorsum_config)
    client.authenticate.should be_true
    client.broadcaster_id("cunningicecoffee").should eq("43784278")
  end

  it "returns the channel details as a JSON::Any when API request is successful" do
    mock_dorsum_twitch_api_authentication_success
    mock_dorsum_twitch_api_channel_success

    client = Dorsum::Twitch::Api::Client.new(build_dorsum_config)
    client.authenticate.should be_true
    channel = client.channel("43784278").as(JSON::Any)
    channel["title"].as_s.should eq("Having fun today 🥳")
    channel["game_name"].as_s.should eq("Fortnite")
  end
end
