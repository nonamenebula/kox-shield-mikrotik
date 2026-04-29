# =====================================================================
#  KOX Shield Mikrotik — uninstall
#  Полностью убирает контейнер, env, mangle/NAT/firewall/routing
#  и address-list-ы созданные KOX Shield.
#
#  Запуск:
#    /tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/uninstall.rsc
#    /import file-name=uninstall.rsc
# =====================================================================

:put ""
:put "============================================================"
:put "  KOX Shield Mikrotik uninstaller"
:put "============================================================"
:put ""

# scheduler
:foreach s in=[/system/scheduler/find name=kox-update] do={ /system/scheduler/remove $s }

# container
:foreach c in=[/container/find hostname=xray-vless] do={
  :do { /container/stop $c } on-error={}
  :delay 2s
  :do { /container/remove $c } on-error={}
}

# env
/container/envs/remove [find list=xvr]

# routes
:foreach r in=[/ip/route/find comment="kox-default"] do={ /ip/route/remove $r }

# firewall (filter / nat / mangle) — всё что мы пометили comment="kox-..."
:foreach r in=[/ip/firewall/filter/find where comment~"^kox-"] do={ /ip/firewall/filter/remove $r }
:foreach r in=[/ip/firewall/nat/find    where comment~"^kox-"] do={ /ip/firewall/nat/remove $r }
:foreach r in=[/ip/firewall/mangle/find where comment~"^kox-"] do={ /ip/firewall/mangle/remove $r }

# address-list-ы и routing-таблица
:foreach a in=[/ip/firewall/address-list/find where list=to_vpn]   do={ /ip/firewall/address-list/remove $a }
:foreach a in=[/ip/firewall/address-list/find where list=RFC1918 comment="kox: RFC1918"] do={ /ip/firewall/address-list/remove $a }
:foreach t in=[/routing/table/find name=r_to_vpn] do={ /routing/table/remove $t }

# IP / интерфейс
:foreach a in=[/ip/address/find interface=docker-xray-vless-veth] do={ /ip/address/remove $a }
:foreach v in=[/interface/veth/find name=docker-xray-vless-veth]  do={ /interface/veth/remove $v }

:put ""
:put "Готово. Все настройки KOX Shield удалены."
:put "ramstorage и пакет container оставлены — отключайте сами при необходимости."
:put ""
