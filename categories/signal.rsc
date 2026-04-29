# KOX Shield — category: Signal (3 entries)
# slug: signal
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=signal.rsc

/ip firewall address-list
add list=to_vpn address=signal.group comment="kox-cat:signal"
add list=to_vpn address=signal.org comment="kox-cat:signal"
add list=to_vpn address=whispersystems.org comment="kox-cat:signal"
