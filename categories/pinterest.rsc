# KOX Shield — category: Pinterest (2 entries)
# slug: pinterest
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=pinterest.rsc

/ip firewall address-list
add list=to_vpn address=pinimg.com comment="kox-cat:pinterest"
add list=to_vpn address=pinterest.com comment="kox-cat:pinterest"
