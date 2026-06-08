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

Установщик **v2** по умолчанию поднимает **sing-box** и скачивает готовый `sing-box.json` с портала KOX Shield — в одном конфиге работают **Hysteria2** и **VLESS+REALITY**.

Трафик к **выбранным сервисам** (YouTube, Telegram, Instagram, X/Twitter, Discord, ChatGPT и т.д.) идёт через VPN, остальное — напрямую через провайдера (split tunnel). Все устройства в LAN защищены без настройки на каждом телефоне/ПК.

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

## 🔑 Подписка KOX Shield

### Рекомендуется — подписка из личного кабинета

1. Зарегистрируйтесь на портале KOX Shield (ссылка в Telegram-канале или у администратора).
2. Во вкладке **MikroTik** скопируйте готовую команду установки — там уже подставлены ваш URL и токен.
3. Вставьте в терминал RouterOS.

Формат подписки (пример, **фиктивные данные**):

```
https://portal.example.com/c/YOUR_TOKEN
```

Установщик сам построит URL конфига sing-box:

```
https://portal.example.com/sb/YOUR_TOKEN?mode=split&device=mikrotik
```

### Legacy — только VLESS (без Hysteria2)

Если в подписке нет HY2 или sing-box.json не скачивается, скрипт переключится на **Xray** в контейнере `catesin/xray-mikrotik-*` и попросит выбрать `vless://` сервер из подписки.

---

## 📦 Установка

### Шаг 1. Подготовьте RouterOS

1. Обновитесь до **RouterOS ≥ 7.20**.
2. Скачайте **Extra packages** под вашу архитектуру с [mikrotik.com/download](https://mikrotik.com/download), залейте `container-*.npk` в `/file` и перезагрузите роутер.
3. Включите container-режим:
   ```routeros
   /system device-mode update container=yes
   ```
   В течение **60 секунд** нажмите **reset** на корпусе (или дождитесь таймаута и перезагрузите).
4. Проверьте:
   ```routeros
   /container/print
   ```

### Шаг 2. Отключите FastTrack

FastTrack пропускает пакеты мимо mangle — KOX без этого не сработает. В `/ip firewall filter` **отключите** правило:
```
chain=forward action=fasttrack-connection ...
```

### Шаг 3. Запустите установщик

#### Вариант A — подписка KOX Shield (рекомендуется, sing-box + HY2)

Скопируйте команду из личного кабинета **MikroTik** или задайте вручную (пример):

```routeros
:global koxSubUrl "https://portal.example.com/c/YOUR_TOKEN"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

Установщик:
1. из URL подписки строит адрес `sing-box.json` на **том же хосте**;
2. скачивает конфиг с портала;
3. поднимает контейнер `ghcr.io/sagernet/sing-box`;
4. настраивает split tunnel и address-list.

> **Важно:** подставьте **свой** URL из личного кабинета, не копируйте `portal.example.com` и `YOUR_TOKEN` из примера.

#### Вариант B — прямой URL sing-box.json

```routeros
:global koxSbUrl "https://portal.example.com/sb/YOUR_TOKEN?mode=split&device=mikrotik"
:global koxSubUrl ""
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант C — legacy: одна vless-ссылка (только Xray)

```routeros
:global koxVlessUri "vless://00000000-0000-4000-8000-000000000001@203.0.113.10:443?type=tcp&security=reality&pbk=REPLACE_ME&sid=a1b2c3d4e5f6&sni=www.example.com&fp=chrome&flow=xtls-rprx-vision#Example"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

#### Вариант D — legacy: поля VLESS по отдельности

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

```routeros
/container/print
# sing-box: hostname=kox-singbox, status=running
/log/print where topics~"container"
/tool/ping 142.250.184.142 routing-table=r_to_vpn
/ip/firewall/address-list/print where list=to_vpn
```

---

## 🗂 Категории доменов

29 категорий доменов и IP — см. [`categories/CATEGORIES.md`](categories/CATEGORIES.md).

```routeros
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/categories/instagram.rsc
/import file-name=instagram.rsc
```

Все категории сразу:

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

**Q: Какой протокол используется?**

По умолчанию **Hysteria2** через sing-box. VLESS+REALITY тоже в конфиге. Legacy-путь (только Xray+VLESS) — если sing-box.json не скачался.

**Q: Не работает YouTube**

```routeros
/container/print where hostname=kox-singbox
/log/print where topics~"container"
/tool/ping 142.250.184.142 routing-table=r_to_vpn
```

**Q: Обновилась подписка на портале**

Переустановите или заново скачайте конфиг:

```routeros
:global koxSubUrl "https://portal.example.com/c/YOUR_TOKEN"
/tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/install.rsc
/import file-name=install.rsc
```

**Q: Нет пакета container**

Архитектуры mipsbe/smips/tile не поддерживают container — см. альтернативу через мини-ПК в README [catesin/Xray-vless-reality-MikroTik](https://github.com/catesin/Xray-vless-reality-MikroTik).

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
