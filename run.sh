#!/bin/bash
#source build-esen.sh

# check if telegram webhook url is present
if [ -z "$WERCKER_TELEGRAM_NOTIFIER_BOT_TOKEN" ]; then
  fail "Please provide a Telegram bot token"
fi

# check if a '#' was supplied in the channel name
if [ -z "$WERCKER_TELEGRAM_NOTIFIER_CHAT_ID" ]; then
  fail "Please provide a Telegram chat id"
fi

# if no icon-url is provided for the bot use the default wercker icon
if [ -z "$WERCKER_TELEGRAM_NOTIFIER_ICON_URL" ]; then
  export WERCKER_TELEGRAM_NOTIFIER_ICON_URL="https://secure.gravatar.com/avatar/a08fc43441db4c2df2cef96e0cc8c045?s=140"
fi

# check if this event is a build or deploy
if [ -n "$DEPLOY" ]; then
  # its a deploy!
  export ACTION="deploy ($WERCKER_DEPLOYTARGET_NAME)"
  export ACTION_URL=$WERCKER_DEPLOY_URL
else
  # its a build!
  export ACTION="build"
  export ACTION_URL=$WERCKER_BUILD_URL
fi

export MESSAGE="[$ACTION]($ACTION_URL) for *${WERCKER_APPLICATION_NAME}* by _${WERCKER_STARTED_BY}_ has *${WERCKER_RESULT}* on branch _${WERCKER_GIT_BRANCH}_"
export SYMBOL="✅"

if [ "$WERCKER_RESULT" = "failed" ]; then
  export MESSAGE="$MESSAGE at step: *${WERCKER_FAILED_STEP_DISPLAY_NAME}*"
  export SYMBOL="❌"
fi

# construct the json
json="
{
    \"chat_id\": \"$WERCKER_TELEGRAM_NOTIFIER_CHAT_ID\",
    \"text\": \"$SYMBOL $MESSAGE\",
    \"parse_mode\": \"Markdown\"
}"
    # \"fallback\": \"$FALLBACK\",
    # \"color\": \"$SYMBOL\"

# skip notifications if not interested in passed builds or deploys
if [ "$WERCKER_TELEGRAM_NOTIFIER_NOTIFY_ON" = "failed" ]; then
	if [ "$WERCKER_RESULT" = "passed" ]; then
		return 0
	fi
fi

# skip notifications if not on the right branch
if [ -n "$WERCKER_TELEGRAM_NOTIFIER_BRANCH" ]; then
    if [ "$WERCKER_TELEGRAM_NOTIFIER_BRANCH" != "$WERCKER_GIT_BRANCH" ]; then
        return 0
    fi
fi

export NOTIFIER_URL="https://api.telegram.org/bot${WERCKER_TELEGRAM_NOTIFIER_BOT_TOKEN}/sendMessage"

# post the result to the telegram webhook
RESULT=$(curl -X POST -H "Content-Type: application/json" -d "$json" -s "$NOTIFIER_URL" --output "$WERCKER_STEP_TEMP"/result.txt -w "%{http_code}")
cat "$WERCKER_STEP_TEMP/result.txt"

if [ "$RESULT" = "500" ]; then
  fail "Error."
fi

if [ "$RESULT" = "404" ]; then
  fail "Not found."
fi
