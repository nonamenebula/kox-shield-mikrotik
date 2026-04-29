# KOX Shield — category: Soundcloud (2 entries)
# slug: soundcloud
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=soundcloud.rsc

/ip firewall address-list
add list=to_vpn address=sndcdn.com comment="kox-cat:soundcloud"
add list=to_vpn address=soundcloud.com comment="kox-cat:soundcloud"
