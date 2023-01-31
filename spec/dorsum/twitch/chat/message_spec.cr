require "../../../spec_helper"

describe Dorsum::Twitch::Chat::Message do
  describe "message with Twitch annotations" do
    it "parses PRIVMSG" do
      text = "@badge-info=subscriber/19;badges=subscriber/2012,sub-gifter/250;client-nonce=8bad5ee77dd34a55c5182ab57187bf8d;color=;display-name=billybobcledus_;emotes=;first-msg=0;flags=;id=1bc70161-2884-4d9d-b3c8-217c71e97c19;mod=0;room-id=43784278;subscriber=1;tmi-sent-ts=1640987950054;turbo=0;user-id=444894547;user-type= :billybobcledus_!billybobcledus_@billybobcledus_.tmi.twitch.tv PRIVMSG #tomato :sweet delicious dry-aged milk"
      message = Dorsum::Twitch::Chat::Message.new(text)
      message.annotations.should eq "badge-info=subscriber/19;badges=subscriber/2012,sub-gifter/250;client-nonce=8bad5ee77dd34a55c5182ab57187bf8d;color=;display-name=billybobcledus_;emotes=;first-msg=0;flags=;id=1bc70161-2884-4d9d-b3c8-217c71e97c19;mod=0;room-id=43784278;subscriber=1;tmi-sent-ts=1640987950054;turbo=0;user-id=444894547;user-type="
      message.source.should eq ":billybobcledus_!billybobcledus_@billybobcledus_.tmi.twitch.tv"
      message.command.should eq "PRIVMSG"
      message.arguments.should eq "#tomato"
      message.channel.should eq "tomato"
      message.message.should eq "sweet delicious dry-aged milk"

      message.display_name.should eq("billybobcledus_")
      message.ansi_color.ansi_code.should eq(231)
      message.badges.should eq(["subscriber/2012", "sub-gifter/250"])
      message.badge.should eq("◇")
      message.sent_at.should eq Time.unix_ms(1640987950054)

      message.formatted_ban_duration.should eq "permanent"
    end

    it "parses CLEARCHAT" do
      text = "@ban-duration=5;room-id=43784278;target-user-id=56789325;tmi-sent-ts=1640996246284 :tmi.twitch.tv CLEARCHAT #tomato :chadow_of_dragnoir"

      message = Dorsum::Twitch::Chat::Message.new(text)
      message.annotations.should eq "ban-duration=5;room-id=43784278;target-user-id=56789325;tmi-sent-ts=1640996246284"
      message.source.should eq ":tmi.twitch.tv"
      message.command.should eq "CLEARCHAT"
      message.arguments.should eq "#tomato"
      message.channel.should eq "tomato"
      message.message.should eq "chadow_of_dragnoir"

      message.formatted_ban_duration.should eq "5s"
    end

    it "parses USERNOTICE" do
      text = "@badge-info=subscriber/26;badges=subscriber/12,bits/5000;color=#DE9027;display-name=teammanfred;emotes=emotesv2_44e58a38550446398c457885e94aab61:0-10;flags=;id=adaff326-8af5-42fd-acb5-91ceb6dd5a8e;login=teammanfred;mod=0;msg-id=resub;msg-param-cumulative-months=26;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(Tomato\\sGaming);msg-param-sub-plan=1000;msg-param-was-gifted=false;room-id=43784278;subscriber=1;system-msg=teammanfred\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s26\\smonths!;tmi-sent-ts=1675189772827;user-id=131842899;user-type= :tmi.twitch.tv USERNOTICE #tomato :tomatoArise"
      message = Dorsum::Twitch::Chat::Message.new(text)
      message.annotations.should eq "badge-info=subscriber/26;badges=subscriber/12,bits/5000;color=#DE9027;display-name=teammanfred;emotes=emotesv2_44e58a38550446398c457885e94aab61:0-10;flags=;id=adaff326-8af5-42fd-acb5-91ceb6dd5a8e;login=teammanfred;mod=0;msg-id=resub;msg-param-cumulative-months=26;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(Tomato\\sGaming);msg-param-sub-plan=1000;msg-param-was-gifted=false;room-id=43784278;subscriber=1;system-msg=teammanfred\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s26\\smonths!;tmi-sent-ts=1675189772827;user-id=131842899;user-type="
      message.source.should eq ":tmi.twitch.tv"
      message.command.should eq "USERNOTICE"
      message.arguments.should eq "#tomato"
      message.channel.should eq "tomato"
      message.message.should eq "tomatoArise"

      message.display_name.should eq("teammanfred")
      message.ansi_color.ansi_code.should eq(179)
      message.badges.should eq(["subscriber/12", "bits/5000"])
      message.badge.should eq("◇")
      message.sent_at.should eq Time.unix_ms(1675189772827)

      message.formatted_ban_duration.should eq "permanent"
    end
  end
end
