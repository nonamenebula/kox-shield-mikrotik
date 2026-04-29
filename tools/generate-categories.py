"""Сгенерировать /opt/kox-shield-mikrotik/categories/*.rsc из proxy_routes БД.

Для каждой категории создаём отдельный .rsc файл со списком address-list записей.
RouterOS поддерживает:
  - address=<cidr>          для IP/CIDR
  - address=<domain>        для FQDN (роутер сам резолвит и обновляет)
Каждой записи проставляем comment=kox-cat:<slug> чтобы update-lists мог
отличать категории друг от друга.
"""
from __future__ import annotations
import os
import re
import sqlite3

DB = "/opt/vpn-portal/data/portal.db"
OUT = "/opt/kox-shield-mikrotik/categories"

ROUTE_SET_ID = 1  # «Заблокированные ресурсы»


SLUG_OVERRIDES = {
    "Twitter / X": "twitter-x",
    "ChatGPT / OpenAI": "chatgpt-openai",
    "Medium / Notion": "medium-notion",
    "GitHub / Dev": "github-dev",
    "Telegram IP (звонки)": "telegram-ip",
    "Прочее": "other",
}


def slugify(name: str) -> str:
    if name in SLUG_OVERRIDES:
        return SLUG_OVERRIDES[name]
    s = name.lower()
    s = s.replace("ё", "e").replace("й", "i")
    table = {
        "а":"a","б":"b","в":"v","г":"g","д":"d","е":"e","ж":"zh","з":"z","и":"i",
        "к":"k","л":"l","м":"m","н":"n","о":"o","п":"p","р":"r","с":"s","т":"t",
        "у":"u","ф":"f","х":"h","ц":"c","ч":"ch","ш":"sh","щ":"shch","ъ":"","ы":"y",
        "ь":"","э":"e","ю":"yu","я":"ya"," ":"-",
    }
    s = "".join(table.get(c, c) for c in s)
    s = re.sub(r"[^a-z0-9_-]+", "-", s).strip("-")
    return s or "cat"


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row

    cats = conn.execute(
        "SELECT id, name, sort_order FROM proxy_route_categories ORDER BY sort_order, id"
    ).fetchall()

    catalog: list[tuple[str, str, int]] = []  # (slug, name, count)
    for cat in cats:
        slug = slugify(cat["name"])
        rows = conn.execute(
            "SELECT kind, pattern FROM proxy_routes "
            "WHERE active=1 AND category_id=? AND route_set_id=? "
            "ORDER BY kind, pattern",
            (cat["id"], ROUTE_SET_ID),
        ).fetchall()
        if not rows:
            continue
        path = os.path.join(OUT, f"{slug}.rsc")
        with open(path, "w", encoding="utf-8") as f:
            f.write(f"# KOX Shield — category: {cat['name']} ({len(rows)} entries)\n")
            f.write(f"# slug: {slug}\n")
            f.write("# Автоматически сгенерировано из portal.db (proxy_routes)\n")
            f.write("# Запуск: /import file-name=" + slug + ".rsc\n")
            f.write("\n")
            f.write("/ip firewall address-list\n")
            for r in rows:
                pat = (r["pattern"] or "").strip()
                if not pat:
                    continue
                f.write(
                    f"add list=to_vpn address={pat} "
                    f'comment="kox-cat:{slug}"\n'
                )
        catalog.append((slug, cat["name"], len(rows)))

    # Создаём _all.rsc — мета-скрипт который грузит всё
    with open(os.path.join(OUT, "_all.rsc"), "w", encoding="utf-8") as f:
        f.write("# KOX Shield — загрузить ВСЕ категории сразу\n")
        f.write("# Запуск: /import file-name=_all.rsc\n")
        f.write("\n")
        f.write(':global koxRepo "https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main"\n\n')
        for slug, name, cnt in catalog:
            f.write(f'# {name} ({cnt})\n')
            f.write(f'/tool/fetch url=("$koxRepo/categories/{slug}.rsc") mode=https dst-path=kox-{slug}.rsc\n')
            f.write(f'/import file-name=kox-{slug}.rsc\n\n')

    # Также сводный CATEGORIES.md — таблица для README
    with open(os.path.join(OUT, "CATEGORIES.md"), "w", encoding="utf-8") as f:
        f.write("# Категории KOX Shield Mikrotik\n\n")
        f.write("| # | Slug | Название | Записей |\n|---|---|---|---|\n")
        for i, (slug, name, cnt) in enumerate(catalog, 1):
            f.write(f"| {i} | `{slug}` | {name} | {cnt} |\n")
        f.write(f"\n**Всего:** {len(catalog)} категорий, "
                f"{sum(c for _,_,c in catalog)} записей.\n")

    print(f"Сгенерировано {len(catalog)} категорий в {OUT}")
    for slug, name, cnt in catalog:
        print(f"  {slug:<25} {name:<25} {cnt:>4}")


if __name__ == "__main__":
    main()
