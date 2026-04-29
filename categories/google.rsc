# KOX Shield — category: Google (4 entries)
# slug: google
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=google.rsc

/ip firewall address-list
add list=to_vpn address=bard.google.com comment="kox-cat:google"
add list=to_vpn address=gemini.google.com comment="kox-cat:google"
add list=to_vpn address=googleusercontent.com comment="kox-cat:google"
add list=to_vpn address=gstatic.com comment="kox-cat:google"
