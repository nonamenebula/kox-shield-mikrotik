# KOX Shield — category: Reddit (6 entries)
# slug: reddit
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=reddit.rsc

/ip firewall address-list
add list=to_vpn address=redd.it comment="kox-cat:reddit"
add list=to_vpn address=reddit.com comment="kox-cat:reddit"
add list=to_vpn address=redditmedia.com comment="kox-cat:reddit"
add list=to_vpn address=redditspace.com comment="kox-cat:reddit"
add list=to_vpn address=redditstatic.com comment="kox-cat:reddit"
add list=to_vpn address=reddituploads.com comment="kox-cat:reddit"
