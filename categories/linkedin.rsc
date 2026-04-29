# KOX Shield — category: LinkedIn (3 entries)
# slug: linkedin
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=linkedin.rsc

/ip firewall address-list
add list=to_vpn address=licdn.com comment="kox-cat:linkedin"
add list=to_vpn address=linkedin.cn comment="kox-cat:linkedin"
add list=to_vpn address=linkedin.com comment="kox-cat:linkedin"
