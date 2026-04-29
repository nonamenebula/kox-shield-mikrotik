# =====================================================================
#  KOX Shield — Mikrotik installer
#  https://github.com/nonamenebula/kox-shield-mikrotik
#
#  Что делает этот скрипт:
#    1. Проверяет что включён container-режим RouterOS
#    2. Создаёт routing-таблицу r_to_vpn и address-list-ы
#    3. Создаёт veth-интерфейс для контейнера (172.18.20.5/30)
#    4. Настраивает mangle / NAT / firewall
#    5. Заводит env-переменные с параметрами VLESS+REALITY
#    6. Скачивает готовый Docker-образ catesin/xray-mikrotik-* и
#       поднимает его как контейнер
#    7. Подгружает базовый набор address-list (Telegram, YouTube, ...)
#    8. Ставит scheduler на ежесуточное обновление списков
#
#  Предполагается что:
#    - RouterOS 7.20+
#    - Включён пакет container (см. README, шаг 2)
#    - На устройстве есть свободное место >=40 МБ
#      (внутреняя память / USB / NVMe)
#
#  Запуск (из терминала RouterOS):
#    /tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
#    /import file-name=install.rsc
# =====================================================================

:global koxVer "1.0"
:global koxRepo "https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main"

:put ""
:put "============================================================"
:put "  KOX Shield Mikrotik installer  v$koxVer"
:put "============================================================"
:put ""

# --- 1. Проверки --------------------------------------------------------------

:local arch [/system resource get architecture-name]
:put "[*] Architecture: $arch"

:local containerEnabled true
:do {
  /container/config/print as-value
} on-error={
  :set containerEnabled false
}
:if (!$containerEnabled) do={
  :put ""
  :put "ОШИБКА: пакет container не активен в RouterOS."
  :put "Включите его одной из команд:"
  :put "  /system device-mode update container=yes"
  :put "и подтвердите физическим нажатием кнопки reset (либо подождите 60 сек."
  :put "и перезагрузите роутер). После этого запустите install.rsc заново."
  :error "container disabled"
}

:local imageTag ""
:if ($arch = "arm64") do={ :set imageTag "catesin/xray-mikrotik-arm64:latest" }
:if ($arch = "arm")   do={ :set imageTag "catesin/xray-mikrotik-arm:latest" }
:if ($arch = "x86_64" or $arch = "amd64") do={ :set imageTag "catesin/xray-mikrotik-amd64:latest" }
:if ([:len $imageTag] = 0) do={
  :put ""
  :put "ОШИБКА: ваша архитектура '$arch' не поддерживается."
  :put "KOX Shield Mikrotik работает только на arm / arm64 / amd64."
  :put "Используйте альтернативную сборку через дополнительный мини-ПК (см. README)."
  :error "unsupported arch"
}
:put "[*] Будет использован образ: $imageTag"

# --- 2. Параметры VLESS ------------------------------------------------------
# Можете задать переменные перед запуском скрипта (через :global) — тогда вопросов не будет.
# Пример:
#   :global koxServerAddress "82.117.255.46"
#   :global koxServerPort "443"
#   :global koxId "42a4aea5-588e-47e3-9c51-3a1aa444fb38"
#   :global koxFlow "xtls-rprx-vision"
#   :global koxFp "chrome"
#   :global koxSni "www.yahoo.com"
#   :global koxPbk "hp0WOIvU-ukbrCz5gFmI_J5Qfo4I-IwKOyL0ysxYMAc"
#   :global koxSid "e1bbe8b50658"
#   :global koxSpx "/"

:global koxServerAddress
:global koxServerPort
:global koxId
:global koxFlow
:global koxFp
:global koxSni
:global koxPbk
:global koxSid
:global koxSpx

:if ([:len $koxServerAddress] = 0) do={ :set koxServerAddress [:input "Server address (host или IP): "] }
:if ([:len $koxServerPort] = 0)    do={ :set koxServerPort    [:input "Server port [443]: "] ; :if ([:len $koxServerPort] = 0) do={ :set koxServerPort "443" } }
:if ([:len $koxId] = 0)            do={ :set koxId            [:input "VLESS UUID: "] }
:if ([:len $koxFlow] = 0)          do={ :set koxFlow          "xtls-rprx-vision" }
:if ([:len $koxFp] = 0)            do={ :set koxFp            "chrome" }
:if ([:len $koxSni] = 0)           do={ :set koxSni           [:input "REALITY SNI: "] }
:if ([:len $koxPbk] = 0)           do={ :set koxPbk           [:input "REALITY publicKey: "] }
:if ([:len $koxSid] = 0)           do={ :set koxSid           [:input "REALITY shortId: "] }
:if ([:len $koxSpx] = 0)           do={ :set koxSpx           "/" }

# --- 3. routing-таблица + address-lists --------------------------------------

:put "[*] Создаём routing-таблицу r_to_vpn..."
:if ([:len [/routing/table/find name=r_to_vpn]] = 0) do={
  /routing/table/add disabled=no fib name=r_to_vpn
}

:put "[*] Создаём address-list RFC1918..."
:foreach net in={"10.0.0.0/8";"172.16.0.0/12";"192.168.0.0/16"} do={
  :if ([:len [/ip/firewall/address-list/find list=RFC1918 address=$net]] = 0) do={
    /ip/firewall/address-list/add list=RFC1918 address=$net comment="kox: RFC1918"
  }
}

# --- 4. veth интерфейс -------------------------------------------------------

:put "[*] Готовим veth-интерфейс для контейнера..."
:if ([:len [/interface/veth/find name=docker-xray-vless-veth]] = 0) do={
  /interface/veth/add address=172.18.20.6/30 gateway=172.18.20.5 gateway6="" \
      name=docker-xray-vless-veth
}
:if ([:len [/ip/address/find interface=docker-xray-vless-veth]] = 0) do={
  /ip/address/add interface=docker-xray-vless-veth address=172.18.20.5/30
}

# --- 5. mangle + NAT + firewall ---------------------------------------------

:put "[*] Настраиваем mangle, NAT, firewall..."

:if ([:len [/ip/firewall/mangle/find comment="kox-rfc1918"]] = 0) do={
  /ip/firewall/mangle/add place-before=([/ip/firewall/mangle/find]->0) \
      action=accept chain=prerouting dst-address-list=RFC1918 \
      in-interface-list=!WAN comment="kox-rfc1918"
}

:if ([:len [/ip/firewall/mangle/find comment="kox-mark-conn"]] = 0) do={
  /ip/firewall/mangle/add action=mark-connection chain=prerouting \
      connection-mark=no-mark dst-address-list=to_vpn in-interface-list=!WAN \
      new-connection-mark=to-vpn-conn passthrough=yes comment="kox-mark-conn"
}

:if ([:len [/ip/firewall/mangle/find comment="kox-mark-route"]] = 0) do={
  /ip/firewall/mangle/add action=mark-routing chain=prerouting \
      connection-mark=to-vpn-conn in-interface-list=!WAN \
      new-routing-mark=r_to_vpn passthrough=yes comment="kox-mark-route"
}

:if ([:len [/ip/firewall/mangle/find comment="kox-mss"]] = 0) do={
  /ip/firewall/mangle/add action=change-mss chain=forward new-mss=1360 \
      out-interface=docker-xray-vless-veth passthrough=yes protocol=tcp \
      tcp-flags=syn tcp-mss=1420-65535 comment="kox-mss"
}

:if ([:len [/ip/firewall/nat/find comment="kox-masq"]] = 0) do={
  /ip/firewall/nat/add action=masquerade chain=srcnat \
      out-interface=docker-xray-vless-veth comment="kox-masq"
}

# Контейнер должен резолвить DNS через RouterOS — открываем 53/udp,tcp
:if ([:len [/ip/firewall/filter/find comment="kox-dns-udp"]] = 0) do={
  /ip/firewall/filter/add chain=input in-interface=docker-xray-vless-veth \
      src-address=172.18.20.6 dst-address=172.18.20.5 protocol=udp \
      dst-port=53 action=accept place-before=([/ip/firewall/filter/find]->0) \
      comment="kox-dns-udp"
}
:if ([:len [/ip/firewall/filter/find comment="kox-dns-tcp"]] = 0) do={
  /ip/firewall/filter/add chain=input in-interface=docker-xray-vless-veth \
      src-address=172.18.20.6 dst-address=172.18.20.5 protocol=tcp \
      dst-port=53 action=accept place-before=([/ip/firewall/filter/find]->0) \
      comment="kox-dns-tcp"
}

# Маршрут по-умолчанию в r_to_vpn ведёт в контейнер
:if ([:len [/ip/route/find comment="kox-default"]] = 0) do={
  /ip/route/add distance=1 dst-address=0.0.0.0/0 gateway=172.18.20.6 \
      routing-table=r_to_vpn comment="kox-default"
}

# --- 6. ramstorage + container env ------------------------------------------

:if ([:len [/disk/find slot=ramstorage]] = 0) do={
  /disk/add slot=ramstorage tmpfs-max-size=100M type=tmpfs
}

# Конфигурация container: registry + tmpdir
/container/config/set tmpdir=ramstorage registry-url=https://registry-1.docker.io

# Удалим старые env (если переустанавливаем)
/container/envs/remove [find list=xvr]

:put "[*] Загружаем VLESS-параметры в env-переменные..."
/container/envs/add list=xvr key=SERVER_ADDRESS value=$koxServerAddress
/container/envs/add list=xvr key=SERVER_PORT    value=$koxServerPort
/container/envs/add list=xvr key=ID             value=$koxId
/container/envs/add list=xvr key=ENCRYPTION     value="none"
/container/envs/add list=xvr key=FLOW           value=$koxFlow
/container/envs/add list=xvr key=FP             value=$koxFp
/container/envs/add list=xvr key=SNI            value=$koxSni
/container/envs/add list=xvr key=PBK            value=$koxPbk
/container/envs/add list=xvr key=SID            value=$koxSid
/container/envs/add list=xvr key=SPX            value=$koxSpx

# --- 7. сам контейнер -------------------------------------------------------

# Удалим старый контейнер если был
:foreach c in=[/container/find hostname=xray-vless] do={
  /container/stop $c
  :delay 2s
  /container/remove $c
}

:put "[*] Скачиваем образ $imageTag (это может занять 1-3 минуты)..."
/container/add hostname=xray-vless interface=docker-xray-vless-veth \
    envlist=xvr root-dir=xray-vless logging=yes start-on-boot=yes \
    remote-image=$imageTag comment="kox-shield"

:put "[*] Ждём окончания распаковки..."
:local ready false
:local tries 0
:while (!$ready && $tries < 60) do={
  :delay 5s
  :set tries ($tries + 1)
  :local st [/container/get [find hostname=xray-vless] status]
  :put "    container status: $st  ($tries/60)"
  :if ($st = "stopped") do={ :set ready true }
}
:if (!$ready) do={
  :put ""
  :put "ВНИМАНИЕ: контейнер не успел распаковаться за 5 минут."
  :put "Проверьте /log print и /container print, при необходимости /container start <id>."
} else={
  :put "[*] Запускаем контейнер..."
  /container/start [find hostname=xray-vless]
}

# --- 8. Базовый набор address-list (категории) ------------------------------

:put "[*] Подгружаем базовые категории address-list (Telegram, YouTube)..."
:do {
  /tool/fetch url=("$koxRepo/categories/telegram.rsc") mode=https dst-path=kox-telegram.rsc
  /import file-name=kox-telegram.rsc
} on-error={ :put "    предупреждение: telegram.rsc не загружен" }

:do {
  /tool/fetch url=("$koxRepo/categories/youtube.rsc") mode=https dst-path=kox-youtube.rsc
  /import file-name=kox-youtube.rsc
} on-error={ :put "    предупреждение: youtube.rsc не загружен" }

# --- 9. scheduler авто-обновления списков -----------------------------------

:if ([:len [/system/scheduler/find name=kox-update]] = 0) do={
  /system/scheduler/add name=kox-update interval=1d start-time=04:00:00 \
      on-event=("/tool/fetch url=\"$koxRepo/update-lists.rsc\" mode=https dst-path=kox-update.rsc; :delay 5s; /import file-name=kox-update.rsc") \
      comment="kox-shield: ежесуточное обновление address-list"
}

# --- 10. Финал --------------------------------------------------------------

:put ""
:put "============================================================"
:put "  УСТАНОВКА ЗАВЕРШЕНА"
:put "============================================================"
:put ""
:put "Что дальше:"
:put "  • Проверить статус:        /container print"
:put "  • Посмотреть лог:          /log print where topics~\"container\""
:put "  • Список address-list:     /ip firewall address-list print where list=to_vpn"
:put "  • Добавить ещё категории:  скачайте categories/*.rsc и /import"
:put "  • Тест туннеля:            /tool ping 172.217.168.206 routing-table=r_to_vpn"
:put ""
:put "Полное руководство и все категории:"
:put "  https://github.com/nonamenebula/kox-shield-mikrotik"
:put ""
