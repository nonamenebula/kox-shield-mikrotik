# KOX Shield — загрузить ВСЕ категории сразу
# Запуск: /import file-name=_all.rsc

:global koxRepo "https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main"

# Telegram (21)
/tool/fetch url=("$koxRepo/categories/telegram.rsc") mode=https dst-path=kox-telegram.rsc
/import file-name=kox-telegram.rsc

# YouTube (7)
/tool/fetch url=("$koxRepo/categories/youtube.rsc") mode=https dst-path=kox-youtube.rsc
/import file-name=kox-youtube.rsc

# WhatsApp (15)
/tool/fetch url=("$koxRepo/categories/whatsapp.rsc") mode=https dst-path=kox-whatsapp.rsc
/import file-name=kox-whatsapp.rsc

# Twitter / X (12)
/tool/fetch url=("$koxRepo/categories/twitter-x.rsc") mode=https dst-path=kox-twitter-x.rsc
/import file-name=kox-twitter-x.rsc

# Instagram (5)
/tool/fetch url=("$koxRepo/categories/instagram.rsc") mode=https dst-path=kox-instagram.rsc
/import file-name=kox-instagram.rsc

# Facebook (18)
/tool/fetch url=("$koxRepo/categories/facebook.rsc") mode=https dst-path=kox-facebook.rsc
/import file-name=kox-facebook.rsc

# Discord (8)
/tool/fetch url=("$koxRepo/categories/discord.rsc") mode=https dst-path=kox-discord.rsc
/import file-name=kox-discord.rsc

# TikTok (8)
/tool/fetch url=("$koxRepo/categories/tiktok.rsc") mode=https dst-path=kox-tiktok.rsc
/import file-name=kox-tiktok.rsc

# Spotify (6)
/tool/fetch url=("$koxRepo/categories/spotify.rsc") mode=https dst-path=kox-spotify.rsc
/import file-name=kox-spotify.rsc

# Netflix (7)
/tool/fetch url=("$koxRepo/categories/netflix.rsc") mode=https dst-path=kox-netflix.rsc
/import file-name=kox-netflix.rsc

# ChatGPT / OpenAI (13)
/tool/fetch url=("$koxRepo/categories/chatgpt-openai.rsc") mode=https dst-path=kox-chatgpt-openai.rsc
/import file-name=kox-chatgpt-openai.rsc

# Google (4)
/tool/fetch url=("$koxRepo/categories/google.rsc") mode=https dst-path=kox-google.rsc
/import file-name=kox-google.rsc

# Steam (7)
/tool/fetch url=("$koxRepo/categories/steam.rsc") mode=https dst-path=kox-steam.rsc
/import file-name=kox-steam.rsc

# Reddit (6)
/tool/fetch url=("$koxRepo/categories/reddit.rsc") mode=https dst-path=kox-reddit.rsc
/import file-name=kox-reddit.rsc

# LinkedIn (3)
/tool/fetch url=("$koxRepo/categories/linkedin.rsc") mode=https dst-path=kox-linkedin.rsc
/import file-name=kox-linkedin.rsc

# Pornhub (9)
/tool/fetch url=("$koxRepo/categories/pornhub.rsc") mode=https dst-path=kox-pornhub.rsc
/import file-name=kox-pornhub.rsc

# Canva (3)
/tool/fetch url=("$koxRepo/categories/canva.rsc") mode=https dst-path=kox-canva.rsc
/import file-name=kox-canva.rsc

# Bing (5)
/tool/fetch url=("$koxRepo/categories/bing.rsc") mode=https dst-path=kox-bing.rsc
/import file-name=kox-bing.rsc

# Medium / Notion (8)
/tool/fetch url=("$koxRepo/categories/medium-notion.rsc") mode=https dst-path=kox-medium-notion.rsc
/import file-name=kox-medium-notion.rsc

# Zoom (4)
/tool/fetch url=("$koxRepo/categories/zoom.rsc") mode=https dst-path=kox-zoom.rsc
/import file-name=kox-zoom.rsc

# Twitch (5)
/tool/fetch url=("$koxRepo/categories/twitch.rsc") mode=https dst-path=kox-twitch.rsc
/import file-name=kox-twitch.rsc

# GitHub / Dev (16)
/tool/fetch url=("$koxRepo/categories/github-dev.rsc") mode=https dst-path=kox-github-dev.rsc
/import file-name=kox-github-dev.rsc

# Soundcloud (2)
/tool/fetch url=("$koxRepo/categories/soundcloud.rsc") mode=https dst-path=kox-soundcloud.rsc
/import file-name=kox-soundcloud.rsc

# Viber (2)
/tool/fetch url=("$koxRepo/categories/viber.rsc") mode=https dst-path=kox-viber.rsc
/import file-name=kox-viber.rsc

# Signal (3)
/tool/fetch url=("$koxRepo/categories/signal.rsc") mode=https dst-path=kox-signal.rsc
/import file-name=kox-signal.rsc

# Clubhouse (2)
/tool/fetch url=("$koxRepo/categories/clubhouse.rsc") mode=https dst-path=kox-clubhouse.rsc
/import file-name=kox-clubhouse.rsc

# Pinterest (2)
/tool/fetch url=("$koxRepo/categories/pinterest.rsc") mode=https dst-path=kox-pinterest.rsc
/import file-name=kox-pinterest.rsc

# Telegram IP (звонки) (13)
/tool/fetch url=("$koxRepo/categories/telegram-ip.rsc") mode=https dst-path=kox-telegram-ip.rsc
/import file-name=kox-telegram-ip.rsc

# Прочее (29)
/tool/fetch url=("$koxRepo/categories/other.rsc") mode=https dst-path=kox-other.rsc
/import file-name=kox-other.rsc

