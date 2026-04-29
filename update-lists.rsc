# =====================================================================
#  KOX Shield Mikrotik — update-lists
#  Скачивает свежие версии всех загруженных категорий address-list
#  с GitHub и применяет.
#
#  Запускается автоматически scheduler-ом kox-update раз в сутки.
#  Можно запустить вручную:
#    /tool fetch url=https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main/update-lists.rsc
#    /import file-name=update-lists.rsc
# =====================================================================

:global koxRepo "https://raw.githubusercontent.com/nonamenebula/kox-shield-mikrotik/main"

:put "[KOX] Обновление address-list..."

# Какие категории уже загружены — определяем по уникальным comment-ам
# Формат комментариев: "kox-cat:<slug>" (см. categories/*.rsc)
:local cats ({})
:foreach a in=[/ip/firewall/address-list/find list=to_vpn] do={
  :local c [/ip/firewall/address-list/get $a comment]
  :if ([:typeof $c] = "str" && [:pick $c 0 8] = "kox-cat:") do={
    :local slug [:pick $c 8 [:len $c]]
    :local seen false
    :foreach existing in=$cats do={ :if ($existing = $slug) do={ :set seen true } }
    :if (!$seen) do={ :set cats ($cats, $slug) }
  }
}

:if ([:len $cats] = 0) do={
  :put "[KOX] Нет загруженных категорий. Нечего обновлять."
} else={
  :foreach slug in=$cats do={
    :put "[KOX]   обновляем категорию: $slug"
    # удаляем старые записи этой категории
    :foreach a in=[/ip/firewall/address-list/find list=to_vpn comment=("kox-cat:" . $slug)] do={
      /ip/firewall/address-list/remove $a
    }
    :do {
      /tool/fetch url=("$koxRepo/categories/" . $slug . ".rsc") mode=https \
          dst-path=("kox-" . $slug . ".rsc")
      /import file-name=("kox-" . $slug . ".rsc")
    } on-error={
      :put "[KOX]     ОШИБКА: не удалось скачать $slug.rsc"
    }
  }
  :put "[KOX] Готово."
}
