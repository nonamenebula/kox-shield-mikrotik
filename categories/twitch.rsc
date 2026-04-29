# KOX Shield — category: Twitch (5 entries)
# slug: twitch
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=twitch.rsc

/ip firewall address-list
add list=to_vpn address=ext-twitch.tv comment="kox-cat:twitch"
add list=to_vpn address=jtvnw.net comment="kox-cat:twitch"
add list=to_vpn address=ttvnw.net comment="kox-cat:twitch"
add list=to_vpn address=twitch.tv comment="kox-cat:twitch"
add list=to_vpn address=twitchcdn.net comment="kox-cat:twitch"
