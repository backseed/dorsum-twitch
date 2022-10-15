require "../../../spec_helper"

describe Dorsum::Twitch::Chat::AnsiColor do
  describe "no color" do
    it "defaults to white" do
      Dorsum::Twitch::Chat::AnsiColor.new(nil).ansi_code.should eq 231
    end
  end

  describe "color" do
    it "converts to an 8bit value between 16 and 231" do
      Dorsum::Twitch::Chat::AnsiColor.new("#000000").ansi_code.should eq 16
      Dorsum::Twitch::Chat::AnsiColor.new("#008000").ansi_code.should eq 34
      Dorsum::Twitch::Chat::AnsiColor.new("#E813A7").ansi_code.should eq 199
      Dorsum::Twitch::Chat::AnsiColor.new("#FF0000").ansi_code.should eq 196
      Dorsum::Twitch::Chat::AnsiColor.new("#FFFFFF").ansi_code.should eq 231
    end
  end
end
