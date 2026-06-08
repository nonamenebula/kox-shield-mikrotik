# =====================================================================
#  KOX Shield — Mikrotik installer
#  https://github.com/nonamenebula/kox-shield-mikrotik
#
#  Что делает этот скрипт:
#    1. Проверяет что включён container-режим RouterOS
#    2. По подписке KOX скачивает sing-box.json (Hysteria2 + VLESS)
#    3. Создаёт routing-таблицу r_to_vpn и address-list-ы
#    4. Создаёт veth-интерфейс для контейнера (172.18.20.5/30)
#    5. Настраивает mangle / NAT / firewall
#    6. Поднимает контейнер ghcr.io/sagernet/sing-box (режим по умолчанию)
#    7. Legacy: при отсутствии HY2 — fallback на Xray+VLESS+REALITY
#    8. Подгружает базовый набор address-list (Telegram, YouTube, ...)
#    9. Ставит scheduler на ежесуточное обновление списков
#
#  Предполагается что:
#    - RouterOS 7.20+
#    - Включён пакет container (см. README, шаг 2)
#    - На устройстве есть свободное место >=40 МБ
#      (внутреняя память / USB / NVMe)
#
#  Самый простой запуск (из терминала RouterOS, всё одной командой):
#    Ссылку возьмите в ЛК https://kox.nonamenebula.ru (вкладка MikroTik) или в боте @kox_nonamenebula_bot
#    :global koxSubUrl "https://kox.nonamenebula.ru/c/YOUR_TOKEN"
#    /tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
#    /import file-name=install.rsc
#
#  Другой провайдер (не KOX) — подписка или vless:
#    :global koxSubUrl "https://portal.example.com/c/YOUR_TOKEN"
#    :global koxVlessUri "vless://<uuid>@<host>:<port>?...#<name>"
#    /tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
#    /import file-name=install.rsc
#
#  Перед /import ОБЯЗАТЕЛЬНО задайте :global koxSubUrl (или koxVlessUri).
#  RouterOS не поддерживает интерактивный ввод (:input) при import.
#
#  Только контейнер (без firewall / маршрутов / списков) — свой роутинг:
#    :global koxMinimal true
# =====================================================================

:global koxVer "2.4"
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
#
# Поддерживаются три способа задать сервер:
#
#   а) подписка (sing-box + HY2 для KOX; legacy Xray для других порталов):
#         KOX:  :global koxSubUrl "https://kox.nonamenebula.ru/c/YOUR_TOKEN"
#         иное: :global koxSubUrl "https://portal.example.com/c/YOUR_TOKEN"
#      Несколько серверов в legacy-режиме — скрипт спросит номер.
#      Заранее: :global koxServerIndex 2
#
#   б) одна vless-ссылка (любой провайдер, только Xray):
#         :global koxVlessUri "vless://<uuid>@<host>:<port>?...#<name>"
#
#   в) поля по отдельности (legacy Xray, только VLESS):
#         :global koxServerAddress "203.0.113.10"
#         :global koxServerPort    "443"
#         :global koxId            "00000000-0000-4000-8000-000000000001"
#         :global koxSni           "www.example.com"
#         :global koxPbk           "REPLACE_WITH_REALITY_PUBLIC_KEY"
#         :global koxSid           "a1b2c3d4e5f6"
#
# Перед import задайте :global koxSubUrl (KOX) или :global koxVlessUri (legacy).

:global koxSubUrl
:global koxVlessUri
:global koxServerIndex
:global koxServerAddress
:global koxServerPort
:global koxId
:global koxFlow
:global koxFp
:global koxSni
:global koxPbk
:global koxSid
:global koxSpx
:global koxMinimal

:if ([:typeof $koxMinimal] = "nothing") do={ :set koxMinimal false }
:if ($koxMinimal) do={
  :put "[*] Rezhim minimal: tolko kontejner (bez firewall, marshrutov, spiskov)"
}

# Проверка: подписка должна быть задана ДО /import
:if ([:len $koxSubUrl] = 0 and [:len $koxVlessUri] = 0 and [:len $koxServerAddress] = 0) do={
  :put ""
  :put "OSHIBKA: ne zadana podpiska."
  :put "Pered /import vypolnite v terminale (svoy token iz LK):"
  :put "  :global koxSubUrl \"https://kox.nonamenebula.ru/c/VASH_TOKEN\""
  :put "Gotovuyu komandu skopiruyte: kox.nonamenebula.ru -> MikroTik"
  :put "ili bot @kox_nonamenebula_bot"
  :error "koxSubUrl not set — zadajte :global koxSubUrl pered import"
}

# --- 2.0 sing-box (VLESS + Hysteria2) — рекомендуется для KOX Shield ---------
:global koxSbUrl
:global koxEngine "xray"
:local useSingbox false

:if ([:len $koxSbUrl] = 0 and [:len $koxSubUrl] > 0) do={
  :local sub $koxSubUrl
  :local cpos [:find $sub "/c/" -1]
  :if ([:typeof $cpos] = "num") do={
    :local tok [:pick $sub ($cpos + 3) [:len $sub]]
    :local slash [:find $tok "/" -1]
    :if ([:typeof $slash] = "num") do={ :set tok [:pick $tok 0 $slash] }
    :local qpos [:find $tok "?" -1]
    :if ([:typeof $qpos] = "num") do={ :set tok [:pick $tok 0 $qpos] }
    :local base [:pick $sub 0 $cpos]
    :if ([:len $tok] >= 8) do={
      :set koxSbUrl ($base . "/sb/" . $tok . "?mode=split&device=mikrotik")
    }
  }
}

:if ([:len $koxSbUrl] > 0) do={
  :put "[*] Режим sing-box: скачиваем конфиг с портала..."
  :do { /file/remove [find name=singbox.json] } on-error={}
  :do {
    /tool/fetch url=$koxSbUrl mode=https dst-path=singbox.json
  } on-error={
    :put "ОШИБКА: не удалось скачать sing-box.json. Проверьте URL и интернет."
    :error "singbox fetch failed"
  }
  :local cfg ""
  :do { :set cfg [/file/get [find name=singbox.json] contents] } on-error={}
  :if ([:len $cfg] < 20) do={
    :put "ОШИБКА: sing-box.json пустой. Проверьте подписку в личном кабинете."
    :error "empty singbox config"
  }
  :set koxEngine "singbox"
  :set useSingbox true
  :put ("[*] Конфиг sing-box загружен (" . [:len $cfg] . " байт)")
}

:if (!$useSingbox) do={

# --- 2.1 Подписка → выбираем сервер → получаем vless-ссылку (legacy Xray) --

:if ([:len $koxSubUrl] > 0 and [:len $koxVlessUri] = 0) do={
  :put "[*] Скачиваем подписку: $koxSubUrl"
  :do { /file/remove [find name=kox-sub.txt] } on-error={}
  :do {
    /tool/fetch url=$koxSubUrl mode=https dst-path=kox-sub.txt
  } on-error={
    :put "ОШИБКА: не удалось скачать подписку. Проверьте URL и доступ в интернет."
    :error "subscription fetch failed"
  }
  :local raw ""
  :do { :set raw [/file/get [find name=kox-sub.txt] contents] } on-error={}
  :do { /file/remove [find name=kox-sub.txt] } on-error={}

  :if ([:len $raw] = 0) do={
    :put "ОШИБКА: пустой ответ подписки."
    :error "empty subscription"
  }

  # Сначала пробуем декодировать как base64 (формат подписки KOX);
  # если не получилось или внутри нет vless:// — берём ответ как есть.
  :local decoded ""
  :do { :set decoded [:convert from=base64 to=raw $raw] } on-error={ :set decoded "" }
  :if ([:typeof $decoded] != "str") do={ :set decoded [:tostr $decoded] }
  :if ([:len $decoded] = 0 or [:typeof [:find $decoded "vless://"]] != "num") do={
    :set decoded [:tostr $raw]
  }

  # Быстрый скан: ищем все вхождения vless:// и режем до ближайшего \n
  :local vlessLines [:toarray ""]
  :local pos 0
  :local doneScan false
  :for n from=1 to=400 do={
    :if (!$doneScan) do={
      :local p [:find $decoded "vless://" $pos]
      :if ([:typeof $p] != "num") do={ :set doneScan true } else={
        :local endP [:find $decoded "\n" ($p + 8)]
        :local endVal [:len $decoded]
        :if ([:typeof $endP] = "num") do={ :set endVal $endP }
        :local line [:pick $decoded $p $endVal]
        :if ([:len $line] > 0) do={
          :local last [:pick $line ([:len $line] - 1) [:len $line]]
          :if ($last = "\r") do={ :set line [:pick $line 0 ([:len $line] - 1)] }
        }
        :set vlessLines ($vlessLines, $line)
        :set pos ($endVal + 1)
      }
    }
  }

  :local nLines [:len $vlessLines]
  :if ($nLines = 0) do={
    :put "ОШИБКА: в подписке не найдено ни одной vless:// ссылки."
    :put "Возможно, подписка пустая или просрочена. Проверьте ЛК."
    :error "no vless servers in subscription"
  }

  :local pickedIdx 1
  :if ($nLines = 1) do={
    :put "[*] В подписке 1 сервер — он и будет использован."
  } else={
    :put ""
    :put "В подписке доступно серверов: $nLines"
    :put "------------------------------------------------------------"
    :local idx 1
    :foreach ln in=$vlessLines do={
      # извлекаем host
      :local body [:pick $ln 8 [:len $ln]]
      :local atPos [:find $body "@" -1]
      :local hp ""
      :if ([:typeof $atPos] = "num") do={ :set hp [:pick $body ($atPos + 1) [:len $body]] }
      :local q1 [:find $hp "?" -1]
      :if ([:typeof $q1] = "num") do={ :set hp [:pick $hp 0 $q1] }
      :local h1 [:find $hp "#" -1]
      :if ([:typeof $h1] = "num") do={ :set hp [:pick $hp 0 $h1] }
      # имя из #fragment (URL-encoded — выводим как есть)
      :local nm "—"
      :local hashPos [:find $ln "#" -1]
      :if ([:typeof $hashPos] = "num") do={ :set nm [:pick $ln ($hashPos + 1) [:len $ln]] }
      :put "  $idx) $hp     $nm"
      :set idx ($idx + 1)
    }
    :put "------------------------------------------------------------"
    :if ([:len $koxServerIndex] > 0) do={
      :set pickedIdx [:tonum $koxServerIndex]
      :put "[*] Server #$pickedIdx (koxServerIndex)"
    } else={
      :set pickedIdx 1
      :put "[*] Neskolko serverov — berem #1. Drugoy: :global koxServerIndex 2"
    }
    :if ([:typeof $pickedIdx] != "num") do={ :error "invalid server choice" }
    :if ($pickedIdx < 1 or $pickedIdx > $nLines) do={ :error "server index out of range: $pickedIdx" }
  }
  :set koxVlessUri ($vlessLines->($pickedIdx - 1))
}

# --- 2.2 vless-ссылка → koxXxx переменные -----------------------------------

:if ([:len $koxVlessUri] > 0) do={
  :local body [:pick $koxVlessUri 8 [:len $koxVlessUri]]
  :local atPos [:find $body "@" -1]
  :if ([:typeof $atPos] != "num") do={ :error "Невалидная vless-ссылка (нет @)" }

  :local uuidPart [:pick $body 0 $atPos]
  :local rest     [:pick $body ($atPos + 1) [:len $body]]
  :local hashPos  [:find $rest "#" -1]
  :if ([:typeof $hashPos] = "num") do={ :set rest [:pick $rest 0 $hashPos] }
  :local qPos     [:find $rest "?" -1]
  :local hp ""
  :local query ""
  :if ([:typeof $qPos] = "num") do={
    :set hp    [:pick $rest 0 $qPos]
    :set query [:pick $rest ($qPos + 1) [:len $rest]]
  } else={
    :set hp $rest
  }

  :local hostP ""
  :local portP "443"
  :local colPos [:find $hp ":" -1]
  :if ([:typeof $colPos] = "num") do={
    :set hostP [:pick $hp 0 $colPos]
    :set portP [:pick $hp ($colPos + 1) [:len $hp]]
  } else={
    :set hostP $hp
  }

  :local pPbk ""; :local pSid ""; :local pSni "";
  :local pFp "chrome"; :local pFlow "xtls-rprx-vision"; :local pSpx "/"
  :if ([:len $query] > 0) do={
    :local qbuf $query
    :while ([:len $qbuf] > 0) do={
      :local sep [:find $qbuf "&" -1]
      :local kv ""
      :if ([:typeof $sep] = "num") do={
        :set kv [:pick $qbuf 0 $sep]
        :set qbuf [:pick $qbuf ($sep + 1) [:len $qbuf]]
      } else={
        :set kv $qbuf
        :set qbuf ""
      }
      :local eq [:find $kv "=" -1]
      :if ([:typeof $eq] = "num") do={
        :local k [:pick $kv 0 $eq]
        :local v [:pick $kv ($eq + 1) [:len $kv]]
        :if ($k = "pbk")  do={ :set pPbk  $v }
        :if ($k = "sid")  do={ :set pSid  $v }
        :if ($k = "sni")  do={ :set pSni  $v }
        :if ($k = "fp")   do={ :set pFp   $v }
        :if ($k = "flow") do={ :set pFlow $v }
        :if ($k = "spx")  do={ :set pSpx  $v }
      }
    }
  }

  # %2F → / (часто встречающийся urlencode для spx)
  :local spxDec ""
  :local i 0
  :while ($i < [:len $pSpx]) do={
    :local ch3 ""
    :if (($i + 3) <= [:len $pSpx]) do={ :set ch3 [:pick $pSpx $i ($i + 3)] }
    :if ($ch3 = "%2F" or $ch3 = "%2f") do={
      :set spxDec ($spxDec . "/")
      :set i ($i + 3)
    } else={
      :set spxDec ($spxDec . [:pick $pSpx $i ($i + 1)])
      :set i ($i + 1)
    }
  }
  :set pSpx $spxDec

  :if ([:len $koxServerAddress] = 0) do={ :set koxServerAddress $hostP }
  :if ([:len $koxServerPort]    = 0) do={ :set koxServerPort    $portP }
  :if ([:len $koxId]            = 0) do={ :set koxId            $uuidPart }
  :if ([:len $koxFlow]          = 0) do={ :set koxFlow          $pFlow }
  :if ([:len $koxFp]            = 0) do={ :set koxFp            $pFp }
  :if ([:len $koxSni]           = 0) do={ :set koxSni           $pSni }
  :if ([:len $koxPbk]           = 0) do={ :set koxPbk           $pPbk }
  :if ([:len $koxSid]           = 0) do={ :set koxSid           $pSid }
  :if ([:len $koxSpx]           = 0) do={ :set koxSpx           $pSpx }

  :put ("[*] Будет использован сервер: " . $koxServerAddress . ":" . $koxServerPort)
}

# --- 2.3 Значения по умолчанию (legacy Xray) ---------------------------------

:if ([:len $koxServerPort] = 0) do={ :set koxServerPort "443" }
:if ([:len $koxFlow] = 0) do={ :set koxFlow "xtls-rprx-vision" }
:if ([:len $koxFp] = 0) do={ :set koxFp "chrome" }
:if ([:len $koxSpx] = 0) do={ :set koxSpx "/" }

:if ([:len $koxServerAddress] = 0 or [:len $koxId] = 0 or [:len $koxPbk] = 0 or [:len $koxSni] = 0 or [:len $koxSid] = 0) do={
  :put "OSHIBKA: dlya legacy ukazhite :global koxVlessUri \"vless://...\""
  :put "ili polya: koxServerAddress, koxId, koxPbk, koxSni, koxSid"
  :error "VLESS params missing"
}

}

# --- 3. routing-таблица + address-lists --------------------------------------

:if (!$koxMinimal) do={
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

:if (!$koxMinimal) do={
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
}

# --- 6. ramstorage + container env ------------------------------------------

:if (!$koxMinimal) do={
:if ([:len [/disk/find slot=ramstorage]] = 0) do={
  /disk/add slot=ramstorage tmpfs-max-size=100M type=tmpfs
}
/container/config/set tmpdir=ramstorage registry-url=https://registry-1.docker.io
}

:local containerHost "xray-vless"
:local containerComment "kox-shield-xray"
:local containerImage $imageTag
:local containerEnv ""

:if ($koxEngine = "singbox") do={
  :set containerHost "kox-singbox"
  :set containerComment "kox-shield-singbox"
  :set containerImage "ghcr.io/sagernet/sing-box:v1.11.7"
  :put "[*] Mount sing-box config (RouterOS /container/mounts)..."
  :do { /container/mounts/remove [find list=kox-singbox-cfg] } on-error={}
  :do { /file/remove [find name="kox-mount/config.json"] } on-error={}
  :do {
    /file/set [find name=singbox.json] name=kox-mount/config.json
  } on-error={
    :put "OSHIBKA: ne udalos peremestit singbox.json v kox-mount/config.json"
    :error "singbox config mount prep failed"
  }
  /container/mounts/add list=kox-singbox-cfg src=kox-mount dst=/etc/sing-box
} else={
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
  :set containerEnv "xvr"
}

# --- 7. сам контейнер -------------------------------------------------------

:foreach c in=[/container/find where comment="kox-shield-xray"] do={
  /container/stop $c
  :delay 2s
  /container/remove $c
}
:foreach c in=[/container/find where comment="kox-shield-singbox"] do={
  /container/stop $c
  :delay 2s
  /container/remove $c
}

:put "[*] Скачиваем образ $containerImage (1-3 минуты)..."
:if ($koxEngine = "singbox") do={
  /container/add hostname=kox-singbox interface=docker-xray-vless-veth \
      root-dir=kox-singbox logging=yes start-on-boot=yes \
      remote-image=$containerImage comment="kox-shield-singbox"
} else={
  /container/add hostname=xray-vless interface=docker-xray-vless-veth \
      envlist=xvr root-dir=xray-vless logging=yes start-on-boot=yes \
      remote-image=$containerImage comment="kox-shield-xray"
}

:put "[*] Zhdem raspakovku obraza..."
:local ready false
:local tries 0
:while (!$ready && $tries < 60) do={
  :delay 5s
  :set tries ($tries + 1)
  :local cid [/container/find where comment=$containerComment]
  :if ([:len $cid] > 0) do={
    :local sz ""
    :do { :set sz [/container/get $cid container-size] } on-error={
      :do { :set sz [/container/get $cid data-size] } on-error={ :set sz "" }
    }
    :if ([:len $sz] > 0 && $sz != "0" && $sz != "0B") do={ :set ready true }
    :if ($tries >= 12) do={ :set ready true }
  }
  :put ("    wait " . $tries . "/60")
}
:if (!$ready) do={
  :put ""
  :put "VNIMANIE: kontejner ne raspakovalsya za 5 minut."
  :put "Prover /container print i /log print"
} else={
  :if ($koxEngine = "singbox") do={
    :put "[*] Podklyuchaem mountlists k sing-box..."
    /container/set [find where comment=$containerComment] mountlists=kox-singbox-cfg
  }
  :put "[*] Zapuskaem kontejner..."
  /container/start [find where comment=$containerComment]
}

# --- 8. Базовый набор address-list (категории) ------------------------------

:if (!$koxMinimal) do={
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
}

# --- 10. Финал --------------------------------------------------------------

:put ""
:put "============================================================"
:put "  УСТАНОВКА ЗАВЕРШЕНА"
:put "============================================================"
:put ""
:put "Chto dalshe:"
:put "  /container print"
:put "  /log print where topics~\"container\""
:if (!$koxMinimal) do={
:put "  /ip firewall address-list print where list=to_vpn"
:put "  /tool ping 172.217.168.206 routing-table=r_to_vpn"
} else={
:put "  Rezhim minimal: marshruty i firewall nastraivay sam"
}
:put ""
:put "Полное руководство и все категории:"
:put "  https://github.com/nonamenebula/kox-shield-mikrotik"
:put ""
