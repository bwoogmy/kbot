# 🤖 kbot

Telegram bot written in Golang using [Cobra](https://github.com/spf13/cobra) and [telebot.v3](https://github.com/tucnak/telebot).

## 🔗 Live Bot!!!

👉 [@bwoogmy_test_bot](https://t.me/bwoogmy_test_bot)

## ⚙️ Installation & Usage

### 1. Clone the repository:
```bash
git clone https://github.com/bwoogmy/kbot.git
cd kbot
```

### 2. Set your bot token as an environment variable:
```bash
export TELE_TOKEN=your_telegram_bot_token
```

### 3. Build the project with version info:
```bash
go build -ldflags "-X=github.com/bwoogmy/kbot/cmd.appVersion=v1.0.3"
```

### 4. Run the bot:
```bash
./kbot start
```

## 💬 Supported Commands

| Message | Action |
|---------|--------|
| `hello` | Replies with bot version |
| `hi`    | Sends a greeting image |
| *other* | Replies with “I don't understand that command.” |

## 🛠 Tech Stack

- Golang 1.21+
- Cobra CLI Framework
- Telebot v3 (Telegram Bot API)
- Telegram BotFather (for token generation)

## 📁 Project Structure

- `cmd/` — CLI commands and bot logic
- `main.go` — CLI entrypoint
- `README.md` — project documentation

## 📝 License

MIT © 2025 bwoogmy
