```
  ██╗  ██╗  ██████╗  ██╗  ██╗      ███╗   ███╗██╗  ██╗████████╗
  ██║ ██╔╝  ██╔══██╗ ╚██╗██╔╝      ████╗ ████║██║ ██╔╝╚══██╔══╝
  █████╔╝   ██║  ██║  ╚███╔╝       ██╔████╔██║█████╔╝    ██║
  ██╔═██╗   ██║  ██║  ██╔██╗       ██║╚██╔╝██║██╔═██╗    ██║
  ██║  ██╗  ╚██████╔╝██╔╝ ██╗      ██║ ╚═╝ ██║██║  ██╗   ██║
  ╚═╝  ╚═╝   ╚═════╝  ╚═╝  ╚═╝      ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝
```

**KOX Shield Mikrotik — VPN на роутерах MikroTik (RouterOS 7.20+ container)**

**Протоколы:** Hysteria2 (QUIC) + VLESS+REALITY через **sing-box** в контейнере.

[![Telegram](https://img.shields.io/badge/Telegram-Канал-blue?logo=telegram)](https://t.me/PrivateProxyKox)
[![Bot](https://img.shields.io/badge/Telegram-Бот-blue?logo=telegram)](https://t.me/kox_nonamenebula_bot)
[![License](https://img.shields.io/badge/Лицензия-MIT-green)](LICENSE)

> **Аналог [KOX Shield для Keenetic](https://github.com/nonamenebula/kox-shield)**, но для роутеров **MikroTik** на RouterOS 7.20+ с включённым пакетом `container`.

---

## 🚀 Что это

Автоматическая установка VPN **прямо на роутер MikroTik** через встроенный механизм контейнеров RouterOS.

Установщик **v2** по умолчанию поднимает **sing-box** и скачивает готовый `sing-box.json` с портала — для подписчиков **KOX Shield** в одном конфиге работают **Hysteria2** и **VLESS+REALITY**. С другими провайдерами возможен режим **Xray + VLESS** (см. варианты C/D).

Трафик к **выбранным сервисам** (YouTube, Telegram, Instagram, X/Twitter, Discord, ChatGPT и т.д.) идёт через VPN, остальное — напрямую через провайдера (split tunnel). Все устройства в LAN защищены без настройки на каждом телефоне/ПК.

> **Подписка KOX** — оформление в [@kox_nonamenebula_bot](https://t.me/kox_nonamenebula_bot), установка одной командой из [личного кабинета](https://kox.nonamenebula.ru). **Свой VPN** — подойдут варианты с `vless://` или полями сервера вручную.

### ✨ Ключевые возможности

| Функция | Описание |
|---|---|
| 🔀 **Умное шифрование (split tunnel)** | через VPN только домены/IP из 29 категорий |
| ⚡ **Hysteria2** | основной протокол KOX Shield (QUIC, быстрый обход) |
| 🔐 **VLESS+REALITY** | поддерживается в том же sing-box-конфиге |
| 📦 **Контейнер на роутере** | без Raspberry Pi и внешних мини-ПК |
| 🏠 **Защита всей LAN** | один раз настроили — работает для всех устройств |
| 🔄 **Авто-обновление списков** | scheduler ежесуточно подтягивает категории с GitHub |
| 🗑️ **Чистый uninstall** | одна команда — все следы KOX удалены |

### ⚠️ Совместимость

| Архитектура | Поддерживается | Примеры моделей |
|---|---|---|
| **arm64** | ✅ | RB5009, hAP ax², hAP ax³, Chateau ax, CCR2004, CCR2116, hEX refresh |
| **arm** (v7) | ✅ | L009UiGS, hEX S, RB4011 (с container-расширением), некоторые CRS |
| **amd64 (x86)** | ✅ | CHR (Cloud Hosted Router), x86 RouterOS |
| **mipsbe / smips / tile** | ❌ | hAP ac², hAP ac³, hAP lite/mini, RB951, RB750 — **container-пакета нет** |

> Точный список: [mikrotik.com/products/matrix](https://mikrotik.com/products/matrix) (фильтр по архитектуре + «package: container» в [release-notes](https://mikrotik.com/download/changelogs)).
>
> **Если container недоступен** — используйте мини-ПК как транзитный шлюз: [catesin/Xray-vless-reality-MikroTik](https://github.com/catesin/Xray-vless-reality-MikroTik) (раздел «Вариант №2»).

---

## ⚡ Быстрый старт (подписка KOX Shield)

Если у вас уже есть подписка KOX — это самый короткий путь:

1. Оформите или продлите подписку в боте **[@kox_nonamenebula_bot](https://t.me/kox_nonamenebula_bot)**
2. Откройте личный кабинет **[kox.nonamenebula.ru](https://kox.nonamenebula.ru)** → вкладка **MikroTik**
3. Скопируйте **готовую команду** (там уже ваш URL и токен) и вставьте в терминал RouterOS
4. Дождитесь окончания установки и проверьте контейнер: `/container/print`

Подготовка RouterOS (container, FastTrack) описана ниже в разделе **Установка** — её нужно сделать **до** запуска скрипта.

---

## 🔑 Откуда взять ссылку на VPN

Установщик принимает **подписку** (`https://...`) или одну **vless-ссылку** (`vless://...`). Что подставлять — зависит от вашего провайдера.

### У вас подписка KOX Shield (рекомендуется)

Готовую команду лучше **не собирать вручную**, а скопировать из личного кабинета — там уже подставлен ваш токен.

| Где взять | Ссылка |
|---|---|
| Telegram-бот | [@kox_nonamenebula_bot](https://t.me/kox_nonamenebula_bot) |
| Личный кабинет | [kox.nonamenebula.ru](https://kox.nonamenebula.ru) → вкладка **MikroTik** |

Формат подписки KOX (в `YOUR_TOKEN` подставьте **свой** токен из ЛК):

```
https://kox.nonamenebula.ru/c/YOUR_TOKEN
```

Установщик сам построит URL конфига sing-box на том же хосте:

```
https://kox.nonamenebula.ru/sb/YOUR_TOKEN?mode=split&device=mikrotik
```

В конфиге будут **Hysteria2** и **VLESS+REALITY** — режим sing-box, это основной сценарий KOX Shield.

### У вас другой провайдер (не KOX)

Скрипт тоже можно использовать, но нужна **ваша** подписка или `vless://` ссылка от провайдера. Ниже — только **фиктивный пример** формата, не копируйте его как есть:

```
https://portal.example.com/c/YOUR_TOKEN
```

Если портал отдаёт готовый `sing-box.json`, можно задать прямой URL (тоже пример):

```
https://portal.example.com/sb/YOUR_TOKEN?mode=split&device=mikrotik
```

Если sing-box.json недоступен — используйте **Вариант C** или **D** ниже: одна `vless://` ссылка или поля сервера вручную. В этом случае поднимется **Xray** (только VLESS+REALITY, без Hysteria2).

---

## 📦 Установка

Команды вставляйте в **New Terminal** в Winbox или в SSH/консоль RouterOS. **Сначала** задаёте `:global koxSubUrl ...`, **затем** `fetch` и `import` — в одной сессии терминала. RouterOS не поддерживает интерактивный ввод при `/import`, подписку нужно указать заранее.

### Шаг 1. Подготовьте RouterOS

1. Обновитесь до **RouterOS ≥ 7.20** ([mikrotik.com/download](https://mikrotik.com/download)).
2. Скачайте **Extra packages** под **вашу** архитектуру (arm / arm64 / amd64), залейте файл `container-*.npk` в **Files** и перезагрузите роутер.
3. Включите container-режим (после команды у вас ~60 секунд на подтверждение):
   ```routeros
   /system device-mode update container=yes
   ```
   Нажмите кнопку **Reset** на корпусе роутера **или** дождитесь таймаута и перезагрузите вручную.
4. Убедитесь, что container доступен (команда не должна выдавать ошибку):
   ```routeros
   /container/print
   ```

### Шаг 2. Отключите FastTrack

FastTrack ускоряет форвардинг, но обходит mangle — трафик к YouTube/Telegram **не попадёт** в VPN.

В Winbox: **IP → Firewall → Filter Rules** — найдите правило `fasttrack-connection` в chain `forward` и **отключите** (Disable).

Или в терминале:
```routeros
/ip/firewall/filter/disable [find chain=forward action=fasttrack-connection]
```

### Шаг 3. Запустите установщик

Выберите **один** вариант по таблице:

| Вариант | Кому подходит | Протокол |
|---|---|---|
| **A** | Подписка **KOX Shield** (из ЛК или бота) | sing-box: HY2 + VLESS |
| **B** | Есть прямой URL `sing-box.json` (KOX или другой портал) | sing-box |
| **C** | Любой провайдер, одна `vless://` ссылка | Xray: только VLESS |
| **D** | Любой провайдер, параметры VLESS вручную | Xray: только VLESS |

Если переменные (`:global koxSubUrl` и т.д.) **не задать** — скрипт спросит ссылку при запуске.

#### Вариант A — подписка KOX Shield (рекомендуется)

**Проще всего:** скопируйте готовый блок из **[kox.nonamenebula.ru](https://kox.nonamenebula.ru)** → **MikroTik** (или из бота [@kox_nonamenebula_bot](https://t.me/kox_nonamenebula_bot)) и вставьте в терминал.

Если собираете вручную — подставьте **свой** токен из ЛК вместо `YOUR_TOKEN`:

```routeros
:global koxSubUrl "https://kox.nonamenebula.ru/c/YOUR_TOKEN"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

Что делает установщик:
1. из `/c/TOKEN` строит адрес `sing-box.json` (`/sb/TOKEN?...`) на том же хосте;
2. скачивает конфиг с портала KOX;
3. поднимает контейнер `ghcr.io/sagernet/sing-box`;
4. настраивает split tunnel и базовые address-list.

#### Вариант B — прямой URL sing-box.json

Когда уже знаете полный URL конфига (из ЛК или от своего портала).

**KOX Shield:**

```routeros
:global koxSbUrl "https://kox.nonamenebula.ru/sb/YOUR_TOKEN?mode=split&device=mikrotik"
:global koxSubUrl ""
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

**Другой портал** (пример, фиктивные данные — подставьте свой URL):

```routeros
:global koxSbUrl "https://portal.example.com/sb/YOUR_TOKEN?mode=split&device=mikrotik"
:global koxSubUrl ""
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант C — одна vless-ссылка (любой провайдер, без HY2)

Подходит, если sing-box.json недоступен. Данные ниже **фиктивные** — вставьте свою `vless://` ссылку:

```routeros
:global koxVlessUri "vless://00000000-0000-4000-8000-000000000001@203.0.113.10:443?type=tcp&security=reality&pbk=REPLACE_ME&sid=a1b2c3d4e5f6&sni=www.example.com&fp=chrome&flow=xtls-rprx-vision#Example"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант D — поля VLESS по отдельности (legacy)

Если нет ни подписки, ни готовой `vless://` строки. Пример с **фиктивными** IP и ключами:

```routeros
:global koxServerAddress "203.0.113.10"
:global koxServerPort    "443"
:global koxId            "00000000-0000-4000-8000-000000000001"
:global koxSni           "www.example.com"
:global koxPbk           "REPLACE_WITH_REALITY_PUBLIC_KEY"
:global koxSid           "a1b2c3d4e5f6"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

### Шаг 4. Проверка

После установки выполните по очереди:

```routeros
/container/print
```

Ожидается контейнер `kox-singbox` со статусом **running** (или `xray-vless` при legacy-режиме).

```routeros
/log/print where topics~"container"
/tool/ping 142.250.184.142 routing-table=r_to_vpn
/ip/firewall/address-list/print where list=to_vpn
```

Ping до Google через таблицу `r_to_vpn` и непустой список `to_vpn` — признак, что маршрутизация настроена. Откройте YouTube или Telegram с устройства в LAN — трафик к ним должен идти через VPN.

---

## 🗂 Категории доменов

При установке подгружается базовый набор (Telegram, YouTube и др.). Полный список — **29 категорий**, описание в [`categories/CATEGORIES.md`](categories/CATEGORIES.md).

Добавить одну категорию вручную:

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/categories/instagram.rsc
/import file-name=instagram.rsc
```

Все категории сразу (если при установке не всё подтянулось):

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/categories/_all.rsc
/import file-name=_all.rsc
```

---

## 🔄 Авто-обновление списков

Scheduler `kox-update` раз в сутки в **04:00** обновляет загруженные категории:

```routeros
/system/scheduler/print where name=kox-update
```

---

## 🏗 Архитектура (sing-box, режим по умолчанию)

```
LAN client (192.168.88.x)
        │
        ▼
[/ip firewall mangle prerouting]
   match: dst-address-list=to_vpn
   →  mark-routing: r_to_vpn
        │
        ▼
[/routing rule]   r_to_vpn → table r_to_vpn
[/ip route]       0.0.0.0/0 via 172.18.20.6
        │
        ▼
[veth docker-xray-vless-veth]   172.18.20.5 ↔ 172.18.20.6
        │
        ▼
[Container kox-singbox]
   ghcr.io/sagernet/sing-box
   config: singbox.json (HY2 + VLESS outbounds, TUN)
        │
        ▼
WAN → интернет (Hysteria2 QUIC или VLESS+REALITY)
```

| Компонент | Назначение |
|---|---|
| **address-list `to_vpn`** | домены/CIDR, идущие через VPN |
| **routing-table `r_to_vpn`** | отдельная таблица → контейнер |
| **kox-singbox** | sing-box: Hysteria2 и VLESS из одного конфига |
| **xray-vless** | legacy-контейнер, только если sing-box недоступен |

---

## 🧰 Полезные команды

```routeros
# Статус контейнера sing-box
/container/print where hostname=kox-singbox

# Перезапуск sing-box
/container/stop [find hostname=kox-singbox]
/container/start [find hostname=kox-singbox]

# Логи
/log/print where topics~"container"

# Активные соединения через туннель
/ip/firewall/connection/print where connection-mark="to-vpn-conn"

# Записей в address-list
:put [:len [/ip/firewall/address-list/find list=to_vpn]]
```

### Быстро выключить / включить туннель

```routeros
/ip/firewall/mangle/disable [find comment="kox-mark-route"]
/ip/firewall/mangle/enable  [find comment="kox-mark-route"]
```

---

## 🗑 Удаление

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/uninstall.rsc
/import file-name=uninstall.rsc
```

Удаляет контейнеры `kox-singbox` и `xray-vless`, правила firewall, маршруты, address-list с пометкой `kox:`.

---

## ❓ FAQ

**Q: У меня нет подписки KOX — можно ли пользоваться скриптом?**

Да. Используйте **Вариант C** или **D** со своей `vless://` ссылкой или параметрами от другого провайдера. Split tunnel и категории доменов работают так же, но без Hysteria2 — только VLESS через Xray.

**Q: Какой протокол используется?**

- **KOX Shield (Вариант A/B):** sing-box, в конфиге **Hysteria2** и **VLESS+REALITY**.
- **Другой провайдер / legacy (Вариант C/D):** Xray, только **VLESS+REALITY**.

**Q: Где взять команду для RouterOS?**

В личном кабинете [kox.nonamenebula.ru](https://kox.nonamenebula.ru) → **MikroTik**, или через бота [@kox_nonamenebula_bot](https://t.me/kox_nonamenebula_bot). Там уже подставлен ваш токен — копируйте целиком.

**Q: Не работает YouTube / Telegram**

1. Проверьте, что FastTrack **отключён** (Шаг 2).
2. Контейнер запущен:
   ```routeros
   /container/print where hostname=kox-singbox
   /log/print where topics~"container"
   /tool/ping 142.250.184.142 routing-table=r_to_vpn
   ```
3. В списке `to_vpn` есть записи: `/ip/firewall/address-list/print where list=to_vpn`

**Q: Обновилась подписка на портале KOX**

Снова скопируйте команду из ЛК **MikroTik** или переустановите вручную (подставьте свой токен):

```routeros
:global koxSubUrl "https://kox.nonamenebula.ru/c/YOUR_TOKEN"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

**Q: Нет пакета container на роутере**

Архитектуры mipsbe / smips / tile (hAP ac², RB750 и др.) **не поддерживают** container. Вариант — мини-ПК как шлюз: [catesin/Xray-vless-reality-MikroTik](https://github.com/catesin/Xray-vless-reality-MikroTik).

---

## 📂 Структура репозитория

```
kox-shield-mikrotik/
├── install.rsc          # установка (sing-box + legacy Xray)
├── uninstall.rsc        # полное удаление
├── update-lists.rsc     # обновление категорий
├── categories/          # 29 категорий address-list
├── tools/
│   └── generate-categories.py
└── README.md
```

---

## 🔧 Используемые компоненты

* **[sing-box](https://github.com/SagerNet/sing-box)** — Hysteria2 + VLESS в одном контейнере (режим по умолчанию).
* **[catesin/xray-mikrotik](https://hub.docker.com/u/catesin)** — legacy Docker-образ Xray (только VLESS, fallback).
* **[Xray-core](https://github.com/XTLS/Xray-core)** — VLESS+REALITY клиент (legacy-путь).
* **RouterOS 7.20+ Container** — OCI-контейнеры на роутере.

Архитектура контейнера на роутере основана на идеях [catesin/Xray-vless-reality-MikroTik](https://github.com/catesin/Xray-vless-reality-MikroTik). Спасибо автору.

---

## 📄 Лицензия

MIT License — используйте свободно, ссылка на проект приветствуется.

---

**[📢 Telegram](https://t.me/PrivateProxyKox)** · **[🤖 Bot](https://t.me/kox_nonamenebula_bot)**
