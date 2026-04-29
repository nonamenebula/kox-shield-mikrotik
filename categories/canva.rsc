# KOX Shield — category: Canva (3 entries)
# slug: canva
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=canva.rsc

/ip firewall address-list
add list=to_vpn address=canva.cn comment="kox-cat:canva"
add list=to_vpn address=canva.com comment="kox-cat:canva"
add list=to_vpn address=static.canva.com comment="kox-cat:canva"
