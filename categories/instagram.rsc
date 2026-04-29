# KOX Shield — category: Instagram (5 entries)
# slug: instagram
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=instagram.rsc

/ip firewall address-list
add list=to_vpn address=cdninstagram.com comment="kox-cat:instagram"
add list=to_vpn address=i.instagram.com comment="kox-cat:instagram"
add list=to_vpn address=instagram.com comment="kox-cat:instagram"
add list=to_vpn address=scontent.cdninstagram.com comment="kox-cat:instagram"
add list=to_vpn address=threads.net comment="kox-cat:instagram"
