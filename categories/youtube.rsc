# KOX Shield — category: YouTube (7 entries)
# slug: youtube
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=youtube.rsc

/ip firewall address-list
add list=to_vpn address=ggpht.com comment="kox-cat:youtube"
add list=to_vpn address=googlevideo.com comment="kox-cat:youtube"
add list=to_vpn address=youtu.be comment="kox-cat:youtube"
add list=to_vpn address=youtube-nocookie.com comment="kox-cat:youtube"
add list=to_vpn address=youtube.com comment="kox-cat:youtube"
add list=to_vpn address=youtube.googleapis.com comment="kox-cat:youtube"
add list=to_vpn address=ytimg.com comment="kox-cat:youtube"
