```
  ██╗  ██╗  ██████╗  ██╗  ██╗      ███╗   ███╗██╗  ██╗████████╗
  ██║ ██╔╝  ██╔══██╗ ╚██╗██╔╝      ████╗ ████║██║ ██╔╝╚══██╔══╝
  █████╔╝   ██║  ██║  ╚███╔╝       ██╔████╔██║█████╔╝    ██║
  ██╔═██╗   ██║  ██║  ██╔██╗       ██║╚██╔╝██║██╔═██╗    ██║
  ██║  ██╗  ╚██████╔╝██╔╝ ██╗      ██║ ╚═╝ ██║██║  ██╗   ██║
  ╚═╝  ╚═╝   ╚═════╝  ╚═╝  ╚═╝      ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝
```

**KOX Shield Mikrotik — умное шифрование трафика для роутеров MikroTik (sing-box: Hysteria2 + VLESS)**

[![Telegram](https://img.shields.io/badge/Telegram-Канал-blue?logo=telegram)](https://t.me/PrivateProxyKox)
[![Bot](https://img.shields.io/badge/Telegram-Бот-blue?logo=telegram)](https://t.me/kox_nonamenebula_bot)
[![Site](https://img.shields.io/badge/🛡️-kox.nonamenebula.ru-blue)](https://kox.nonamenebula.ru/register)
[![License](https://img.shields.io/badge/Лицензия-MIT-green)](LICENSE)

> **Аналог [KOX Shield для Keenetic](https://github.com/nonamenebula/kox-shield)**, но для роутеров **MikroTik** на RouterOS 7.20+ с включённым пакетом `container`.

---

## 🚀 Что это

Полностью автоматизированная установка VLESS/REALITY-туннеля **прямо на роутер MikroTik** через встроенный механизм контейнеров RouterOS. Трафик к **выбранным сервисам** (YouTube, Telegram, Instagram, X/Twitter, Discord, ChatGPT и т.д.) идёт через VPN, всё остальное — напрямую через провайдера. Все устройства локальной сети получают защиту автоматически, без настройки на каждом устройстве.

### ✨ Ключевые возможности

| Функция | Описание |
|---|---|
| 🔀 **Умное шифрование (split tunnel)** | через VPN идут только домены/IP из 29 категорий, остальное напрямую |
| ⚡ **Hysteria2 + VLESS** | sing-box в контейнере: HY2 (QUIC) и VLESS+REALITY |
| 📦 **Контейнер на самом роутере** | никаких внешних мини-ПК, Raspberry Pi и т.п. |
| 🏠 **Защита всей LAN** | один раз настроили — работает для телефонов, ТВ, ПК |
| 🔄 **Авто-обновление списков** | scheduler ежесуточно подтягивает свежие категории с GitHub |
| 🗑️ **Чистый uninstall** | одна команда, и все следы KOX удалены |

### ⚠️ Совместимость

| Архитектура | Поддерживается | Примеры моделей |
|---|---|---|
| **arm64** | ✅ | RB5009, hAP ax², hAP ax³, Chateau ax, CCR2004, CCR2116, hEX refresh |
| **arm** (v7) | ✅ | L009UiGS, hEX S, RB4011 (с container-расширением), некоторые CRS |
| **amd64 (x86)** | ✅ | CHR (Cloud Hosted Router), x86 RouterOS |
| **mipsbe / smips / tile** | ❌ | hAP ac², hAP ac³, hAP lite/mini, RB951, RB750 — **container-пакета нет** |

> Точный список совместимых моделей: [mikrotik.com/products/matrix](https://mikrotik.com/products/matrix) (фильтр по архитектуре + смотреть «package: container» в [release-notes RouterOS](https://mikrotik.com/download/changelogs)).
>
> **Если у вас старая модель без `container`** — KOX Shield Mikrotik **не поставится**. Используйте альтернативный способ (Raspberry Pi/мини-ПК как тран­зит­ный шлюз) — описан в репозитории [`catesin/Xray-vless-reality-MikroTik`](https://github.com/catesin/Xray-vless-reality-MikroTik) (раздел «Вариант №2»).

---

## 🔑 Подписка KOX Shield (VLESS + Hysteria2)

### Готовая подписка KOX Shield (1 минута)

Зарегистрируйтесь на **[kox.nonamenebula.ru/register](https://kox.nonamenebula.ru/register)** — получите подписку с несколькими серверами и автообновлением. На странице вашего личного кабинета во вкладке **MikroTik** будет готовая команда установки со всеми параметрами уже подставленными — копируйте и вставляйте.

### Свой VLESS-сервер

См. [README основного репозитория KOX Shield](https://github.com/nonamenebula/kox-shield#-откуда-взять-vless-сервер) — там подробно как поднять Xray на VPS.

---

## 📦 Установка

### Шаг 1. Подготовьте RouterOS

1. Обновитесь до **RouterOS ≥ 7.20**.
2. Скачайте «**Extra packages**» под вашу архитектуру с [mikrotik.com/download](https://mikrotik.com/download), распакуйте zip, **залейте `container-*.npk`** в `/file` через WinBox/WebFig и перезагрузите роутер.
3. Включите container-режим:
   ```routeros
   /system device-mode update container=yes
   ```
   В течение **60 секунд** нажмите кнопку **reset** на корпусе роутера (или подождите тайм­аут и перезагрузите). Это требование безопасности RouterOS.
4. Проверьте что `/container` в меню появился:
   ```routeros
   /container/print
   ```

### Шаг 2. Отключите FastTrack

FastTrack пропускает пакеты мимо mangle — KOX без этого не сработает. Откройте `/ip firewall filter` и **отключите** правило:
```
chain=forward action=fasttrack-connection ...
```
В стандартной конфигурации Mikrotik это первое или второе правило. Можно через WinBox правой кнопкой → Disable.

### Шаг 3. Запустите установщик

В терминале роутера (WinBox → New Terminal или SSH).

#### Вариант A — подписка KOX Shield (рекомендуется)

Если у вас подписка KOX, в Личном Кабинете на вкладке **MikroTik** нажмите «Скопировать», а затем вставьте в терминал:

```routeros
:global koxSubUrl "https://kox.nonamenebula.ru/c/<ВАШ_ТОКЕН>"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

Установщик **v2** сам построит URL конфига sing-box (`/sb/<token>?mode=split&device=mikrotik`) и поднимет контейнер `ghcr.io/sagernet/sing-box` — работают и **Hysteria2**, и VLESS из одной подписки.

Скрипт сам:
1. скачает подписку,
2. декодирует base64,
3. найдёт все vless-ссылки внутри,
4. **если серверов несколько — покажет список и спросит номер**:
   ```
   В подписке доступно серверов: 4
   ------------------------------------------------------------
     1) 77.105.162.239     %F0%9F%87%BA%F0%9F%87%B8%20%D0%A1%D0%A8%D0%90
     2) 82.117.255.46      %F0%9F%87%B7%F0%9F%87%B4%20%D0%A0%D1%83%D0%BC%D1%8B%D0%BD%D0%B8%D1%8F
     3) ...
   ------------------------------------------------------------
   Выберите сервер [1-4], Enter = 1:
   ```
   *(имена в подписке URL-encoded — ориентируйтесь по адресу)*
5. развернёт контейнер и поднимет туннель.

Чтобы выбрать сервер заранее без вопроса:
```routeros
:global koxServerIndex 2
:global koxSubUrl "https://kox.nonamenebula.ru/c/<ВАШ_ТОКЕН>"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант B — одна vless-ссылка

```routeros
:global koxVlessUri "vless://<uuid>@host:port?type=tcp&security=reality&pbk=...&sid=...&sni=...&fp=chrome&flow=xtls-rprx-vision#name"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант C — поля по отдельности

```routeros
:global koxServerAddress "82.117.255.46"
:global koxServerPort    "443"
:global koxId            "42a4aea5-588e-47e3-9c51-3a1aa444fb38"
:global koxSni           "www.yahoo.com"
:global koxPbk           "hp0WOIvU-ukbrCz5gFmI_J5Qfo4I-IwKOyL0ysxYMAc"
:global koxSid           "e1bbe8b50658"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант D — без подсказок

Если запустить просто:
```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```
скрипт сначала спросит ссылку (подписка/vless/пустую — для ручного ввода полей), а затем — недостающие параметры.

### Шаг 4. Проверка

После установки убедитесь что контейнер запустился:
```routeros
/container/print
# должно быть: status=running
/log/print where topics~"container"
```

Пинг через туннель:
```routeros
/tool/ping 142.250.184.142 routing-table=r_to_vpn
# (это IP youtube.com — должен пинговаться через VPN)
```

В address-list должны быть записи:
```routeros
/ip/firewall/address-list/print where list=to_vpn
```

---

## 🗂 Категории доменов

KOX Shield Mikrotik поставляется с **29 категориями** доменов и IP. См. [`categories/CATEGORIES.md`](categories/CATEGORIES.md) — полный список с количеством записей.

### Загрузить отдельную категорию

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/categories/instagram.rsc
/import file-name=instagram.rsc
```

### Загрузить ВСЕ категории сразу

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/categories/_all.rsc
/import file-name=_all.rsc
```

> ⚠️ Это добавит **~250 записей** в address-list. На слабых моделях (256 МБ RAM) лучше загружать только нужные категории.

### Удалить категорию

```routeros
:foreach a in=[/ip/firewall/address-list/find list=to_vpn comment="kox-cat:instagram"] do={ /ip/firewall/address-list/remove $a }
```

### Добавить свой сайт

```routeros
/ip/firewall/address-list/add list=to_vpn address=mysite.com comment="kox-manual"
```

---

## 🔄 Авто-обновление

Установщик создаёт scheduler `kox-update`, который раз в сутки в **04:00** скачивает свежие версии всех загруженных категорий с GitHub:

```routeros
/system/scheduler/print where name=kox-update
```

Принудительное обновление вручную:
```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/update-lists.rsc
/import file-name=update-lists.rsc
```

---

## 🏗 Архитектура

```
LAN client (192.168.88.x)
        │
        ▼
[/ip firewall mangle prerouting]
   match: in-interface-list=!WAN AND dst-address-list=to_vpn
   →  mark-connection: to-vpn-conn
   →  mark-routing:    r_to_vpn
        │
        ▼
[/routing rule]   routing-mark=r_to_vpn → table=r_to_vpn
[/ip route]       0.0.0.0/0 via 172.18.20.6 (контейнер)
        │
        ▼
[veth: docker-xray-vless-veth]   172.18.20.5 (router) ↔ 172.18.20.6 (container)
        │
        ▼
[Container catesin/xray-mikrotik-*]
   внутри: dnsmasq + Xray-core с VLESS+REALITY outbound
        │
        ▼
WAN (eth1) → провайдер → VPS-сервер (TLS+REALITY) → Интернет
```

| Компонент | Что делает |
|---|---|
| **address-list `to_vpn`** | список доменов и CIDR, к которым нужно идти через VPN |
| **address-list `RFC1918`** | private-сети (10/8, 172.16/12, 192.168/16) — никогда не идут в туннель, чтобы не потерять управление |
| **routing-table `r_to_vpn`** | отдельная таблица маршрутизации с default → контейнер |
| **mangle prerouting** | помечает соединение и пакеты для попадания в `r_to_vpn` |
| **veth `docker-xray-vless-veth`** | виртуальная пара /30 между роутером и контейнером |
| **NAT masquerade** | маскарадинг трафика, уходящего в контейнер (иначе обратный трафик не вернётся) |
| **firewall filter (53/udp,tcp)** | разрешает контейнеру резолвить DNS через RouterOS |
| **change-mss 1360** | предохраняет от фрагментации внутри REALITY-туннеля |

---

## 🧰 Полезные команды

```routeros
# Статус контейнера
/container/print

# Логи контейнера (последние ошибки Xray)
/log/print where topics~"container"

# Перезапустить контейнер
/container/stop [find hostname=xray-vless]
/container/start [find hostname=xray-vless]

# Сменить параметры сервера
/container/envs/set [find list=xvr key=SERVER_ADDRESS] value=new.server.com
/container/stop [find hostname=xray-vless]
/container/start [find hostname=xray-vless]

# Посмотреть что идёт через туннель прямо сейчас
/ip/firewall/connection/print where connection-mark="to-vpn-conn"

# Полная статистика mangle-правила (попадания)
/ip/firewall/mangle/print stats

# Сколько сейчас в address-list
:put [:len [/ip/firewall/address-list/find list=to_vpn]]
```

---

## 🗑 Удаление

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/uninstall.rsc
/import file-name=uninstall.rsc
```

Удалит:
* контейнер + образ
* env-переменные
* все правила mangle/NAT/filter с `comment="kox-..."`
* маршрут по-умолчанию в `r_to_vpn`
* address-list-ы `to_vpn` и `RFC1918` (только записи с пометкой `kox:`)
* routing-таблицу `r_to_vpn`
* veth-интерфейс
* scheduler `kox-update`

Пакет `container` и ramstorage **НЕ** удаляются — выключаете при необходимости вручную.

---

## ❓ FAQ

**Q: Не работает YouTube после установки**

```routeros
/container/print              # status должен быть running
/log/print where topics~"container"      # есть ошибки?
/tool/ping 142.250.184.142 routing-table=r_to_vpn  # туннель живой?
```
Если ping не идёт — проверьте параметры VLESS (особенно `pbk`, `sid`, `sni`) и что VPS-сервер доступен с роутера: `/tool/ping <SERVER_IP>` (без routing-table — должен пинговаться напрямую).

**Q: На моём роутере нет пакета container**

Архитектуры **mipsbe/smips/tile** не поддерживают container в принципе — ограничение MikroTik. Используйте мини-ПК (Raspberry Pi, OrangePi, любой x86) с Debian + Xray + tun2socks как тран­зит­ный шлюз. Подробнее: [catesin/Xray-vless-reality-MikroTik#R_Xray_2](https://github.com/catesin/Xray-vless-reality-MikroTik#вариант-2-routeros-без-контейнера).

**Q: Хочу включить/выключить туннель быстро (для банков)**

Самый простой способ — отключить mangle-правило с пометкой `kox-mark-route`:
```routeros
/ip/firewall/mangle/disable [find comment="kox-mark-route"]   # выключить туннель
/ip/firewall/mangle/enable  [find comment="kox-mark-route"]   # включить обратно
```

**Q: У меня поменялись параметры подписки**

```routeros
/container/envs/set [find list=xvr key=ID]  value=new-uuid
/container/envs/set [find list=xvr key=PBK] value=new-pbk
/container/envs/set [find list=xvr key=SID] value=new-sid
/container/stop  [find hostname=xray-vless]
/container/start [find hostname=xray-vless]
```

**Q: Хочу обновить контейнер до новой версии**

```routeros
/container/stop [find hostname=xray-vless]
/container/remove [find hostname=xray-vless]
/container/add hostname=xray-vless interface=docker-xray-vless-veth \
    envlist=xvr root-dir=xray-vless logging=yes start-on-boot=yes \
    remote-image=catesin/xray-mikrotik-arm64:latest
# (замените arm64 на свою архитектуру)
```

**Q: scheduler не запускается, обновления не приходят**

Проверьте время на роутере и наличие интернета:
```routeros
/system/clock/print
/tool/fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/update-lists.rsc mode=https
```
Если fetch не работает по https — проверьте что в `/certificate/print` есть корневые сертификаты (CA root). Можно подгрузить пакетом `extras` с mikrotik.com.

---

## 📂 Структура репозитория

```
kox-shield-mikrotik/
├── install.rsc                # ставит всё одной командой
├── uninstall.rsc              # удаляет всё одной командой
├── update-lists.rsc           # перекачивает все загруженные категории
├── categories/
│   ├── _all.rsc               # импорт всех 29 категорий разом
│   ├── CATEGORIES.md          # таблица: категория → slug → кол-во записей
│   ├── telegram.rsc
│   ├── youtube.rsc
│   ├── instagram.rsc
│   └── ... (29 файлов всего)
├── tools/
│   └── generate-categories.py # пересоздать .rsc из proxy_routes БД
└── README.md
```

---

## 🔧 Используемые компоненты

* **[catesin/xray-mikrotik](https://hub.docker.com/u/catesin)** — готовые Docker-образы Xray под архитектуры RouterOS (arm/arm64/amd64). Идея архитектуры контейнера полностью основана на проекте [catesin/Xray-vless-reality-MikroTik](https://github.com/catesin/Xray-vless-reality-MikroTik) (236 ⭐). Огромное спасибо автору.
* **[Xray-core](https://github.com/XTLS/Xray-core)** — собственно VLESS+REALITY клиент.
* **RouterOS 7.20+ Container** — нативный механизм запуска OCI-образов на роутере.

---

## 📄 Лицензия

MIT License — используйте свободно, ссылка на проект приветствуется.

---

**[🌐 kox.nonamenebula.ru](https://kox.nonamenebula.ru/register)** · **[📢 Telegram](https://t.me/PrivateProxyKox)** · **[🤖 Bot](https://t.me/kox_nonamenebula_bot)**
