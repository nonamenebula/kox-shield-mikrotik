# KOX Shield — category: Spotify (6 entries)
# slug: spotify
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=spotify.rsc

/ip firewall address-list
add list=to_vpn address=audio-sp-*.spotifycdn.net comment="kox-cat:spotify"
add list=to_vpn address=scdn.co comment="kox-cat:spotify"
add list=to_vpn address=spotify.com comment="kox-cat:spotify"
add list=to_vpn address=spotify.design comment="kox-cat:spotify"
add list=to_vpn address=spotifycdn.com comment="kox-cat:spotify"
add list=to_vpn address=spotilocal.com comment="kox-cat:spotify"
