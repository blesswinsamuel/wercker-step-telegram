# step-telegram

A telegram notifier written in `bash` and `curl`. Make sure you create a Telegram
bot first (see the Telegram bot api to set one up).

[![wercker status](https://app.wercker.com/status/654399baedda7da5b236e4de6aca1231/s "wercker status")](https://app.wercker.com/project/bykey/654399baedda7da5b236e4de6aca1231)

# Options

- `bot_token` The Telegram bot token
- `chat_id` Chat id
- `notify_on` (optional) If set to `failed`, it will only notify on failed
builds or deploys.
- `branch` (optional) If set, it will only notify on the given branch


# Example

```yaml
build:
    after-steps:
        - blesswinsamuel/telegram-notifier:
            bot\_token: $TELEGRAM\_BOT\_TOKEN
            chat\_id: $CHAT\_ID
            branch: master
```

# License

The MIT License (MIT)

# Changelog

## 1.0.0

- Initial release
