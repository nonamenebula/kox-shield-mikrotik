# KOX Shield — category: Bing (5 entries)
# slug: bing
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=bing.rsc

/ip firewall address-list
add list=to_vpn address=bing.com comment="kox-cat:bing"
add list=to_vpn address=bing.net comment="kox-cat:bing"
add list=to_vpn address=bingapis.com comment="kox-cat:bing"
add list=to_vpn address=copilot.microsoft.com comment="kox-cat:bing"
add list=to_vpn address=sydney.bing.com comment="kox-cat:bing"
