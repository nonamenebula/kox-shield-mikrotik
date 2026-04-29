# KOX Shield — category: Zoom (4 entries)
# slug: zoom
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=zoom.rsc

/ip firewall address-list
add list=to_vpn address=zoom.com comment="kox-cat:zoom"
add list=to_vpn address=zoom.us comment="kox-cat:zoom"
add list=to_vpn address=zoomcdn.com comment="kox-cat:zoom"
add list=to_vpn address=zoomgov.com comment="kox-cat:zoom"
