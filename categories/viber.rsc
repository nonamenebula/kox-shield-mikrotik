# KOX Shield — category: Viber (2 entries)
# slug: viber
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=viber.rsc

/ip firewall address-list
add list=to_vpn address=viber.com comment="kox-cat:viber"
add list=to_vpn address=viber.media comment="kox-cat:viber"
