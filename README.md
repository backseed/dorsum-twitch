# Dorsum Twitch

Ingests data from Twitch chat and Twitch APIs, and executes configurable commands on triggers.

## Replies

Dorsum can automatically reply to certain messages or events in chat.

```yaml
- replies:
  - detect: discord
    sensitive: false
    reply: "@{{display-name}}: join here: https://discord.gg/xxxxx"
    cooldown: 5m
  - command: title
    reply: "@{{display-name}}: {{channel.title}} ({{channel.game_name}})"
  - command: socials
    allow: [mod,subscriber]
    reply: "@{{display-name}}: https://twitter.com/tom"
  - detect: ~
    when: [first-message]
```

### Variables

When responding to a message, all the details about the message are in the global namespace:

```yaml
display-name: "LittlePogChamp"
```

Channel details can be accessed through the `channel` object:

```yaml
channel:
  title: "Looking for a W 🔥"
  game_name: "Fortnite"
```

## Duration

Dorsum uses its own notation for duration, wait time, and cooldowns. It's basically a list of duration expressions which are added up to form one single duration.

```
# 5 minutes
5m

# 1 hours and 5 minutes
1h 5m
1h5m
5m1h

# 2 days and 1 second
2d1s
```

Supported memos are:

```yaml
d: days
h: hours
m: minutes
s: seconds
```

These specifically don't include years, months, nor weeks because they are usually used for live events where this kind of time doesn't have to be expressed.