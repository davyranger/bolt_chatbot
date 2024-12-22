import os
from slack_bolt import App

# Initializes your app with your bot token and signing secret
app = App(
    token=os.environ.get("SLACK_BOT_TOKEN"),
    signing_secret=os.environ.get("SLACK_SIGNING_SECRET")
)

# Listens to incoming messages that contain "hello"
@app.message("hello")
def message_hello(message, say):
    user_id = message.get('user', 'unknown_user')
    print(f"Received message from {user_id}")
    say(
        blocks=[{
            "type": "section",
            "text": {
                "type": "mrkdwn", 
                "text": f"Hey there <@{user_id}>!"  # User mention as part of the message
            },
            "accessory": {
                "type": "button",
                "text": {"type": "plain_text", "text": "Click Me"},
                "action_id": "button_click"
            }
        }],
        text=f"Hey there <@{user_id}>!"
    )

# Start your app
if __name__ == "__main__":
    app.start(port=int(os.environ.get("PORT", 3000)))