# KOX Shield — category: Steam (7 entries)
# slug: steam
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=steam.rsc

/ip firewall address-list
add list=to_vpn address=steamcdn-a.akamaihd.net comment="kox-cat:steam"
add list=to_vpn address=steamcommunity.com comment="kox-cat:steam"
add list=to_vpn address=steamcontent.com comment="kox-cat:steam"
add list=to_vpn address=steamgames.com comment="kox-cat:steam"
add list=to_vpn address=steampowered.com comment="kox-cat:steam"
add list=to_vpn address=steamstatic.com comment="kox-cat:steam"
add list=to_vpn address=store.steampowered.com comment="kox-cat:steam"
