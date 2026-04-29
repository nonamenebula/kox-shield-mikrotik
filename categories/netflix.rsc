# KOX Shield — category: Netflix (7 entries)
# slug: netflix
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=netflix.rsc

/ip firewall address-list
add list=to_vpn address=fast.com comment="kox-cat:netflix"
add list=to_vpn address=netflix.com comment="kox-cat:netflix"
add list=to_vpn address=netflix.net comment="kox-cat:netflix"
add list=to_vpn address=nflxext.com comment="kox-cat:netflix"
add list=to_vpn address=nflximg.net comment="kox-cat:netflix"
add list=to_vpn address=nflxso.net comment="kox-cat:netflix"
add list=to_vpn address=nflxvideo.net comment="kox-cat:netflix"
