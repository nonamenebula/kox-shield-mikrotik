# KOX Shield — category: ChatGPT / OpenAI (13 entries)
# slug: chatgpt-openai
# Автоматически сгенерировано из portal.db (proxy_routes)
# Запуск: /import file-name=chatgpt-openai.rsc

/ip firewall address-list
add list=to_vpn address=anthropic.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=api.openai.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=auth0.openai.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=cdn.openai.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=chat.openai.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=chatgpt.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=claude.ai comment="kox-cat:chatgpt-openai"
add list=to_vpn address=cursor.sh comment="kox-cat:chatgpt-openai"
add list=to_vpn address=files.oaiusercontent.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=oaistatic.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=oaiusercontent.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=openai.com comment="kox-cat:chatgpt-openai"
add list=to_vpn address=platform.openai.com comment="kox-cat:chatgpt-openai"
