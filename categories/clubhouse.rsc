# KOX Shield — category: Clubhouse (2 entries)
# slug: clubhouse
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=clubhouse.rsc

/ip firewall address-list
add list=to_vpn address=clubhouse.com comment="kox-cat:clubhouse"
add list=to_vpn address=joinclubhouse.com comment="kox-cat:clubhouse"
