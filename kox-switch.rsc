# List locations or switch without reinstalling.
# List:    /import file-name=kox-switch.rsc
# Switch:  :global koxServerIndex 2
#          /import file-name=kox-switch.rsc
# Subscription: :global koxSubUrl or file kox-sub.url

:global koxSubUrl
:global koxServerIndex

:local sub ""
:if ([:typeof $koxSubUrl] = "str" and [:len $koxSubUrl] > 0) do={
  :set sub $koxSubUrl
}
:if ([:len $sub] = 0) do={
  :do { :set sub [/file/get [find name=kox-sub.url] contents] } on-error={ :set sub "" }
}
:if ([:len $sub] = 0) do={
  :put "Net podpiski. Zadajte: :global koxSubUrl \"https://kox.nonamenebula.ru/c/TOKEN\""
  :error "no subscription"
}

:local cpos [:find $sub "/c/" -1]
:if ([:typeof $cpos] != "num") do={
  :put "Nuzhna podpiska vida https://.../c/TOKEN"
  :error "bad subscription"
}
:local tok [:pick $sub ($cpos + 3) [:len $sub]]
:local slash [:find $tok "/" -1]
:if ([:typeof $slash] = "num") do={ :set tok [:pick $tok 0 $slash] }
:local qpos [:find $tok "?" -1]
:if ([:typeof $qpos] = "num") do={ :set tok [:pick $tok 0 $qpos] }
:local base [:pick $sub 0 $cpos]
:local listUrl ($base . "/sb/" . $tok . "/servers?mode=split&ascii=1")
:local cfgUrl ($base . "/sb/" . $tok . "?mode=split&device=mikrotik")

:local wantSwitch false
:local idx 0
:if ([:typeof $koxServerIndex] = "num") do={
  :set wantSwitch true
  :set idx $koxServerIndex
}
:if ([:typeof $koxServerIndex] = "str" and [:len $koxServerIndex] > 0) do={
  :set wantSwitch true
  :set idx [:tonum $koxServerIndex]
}

:if (!$wantSwitch) do={
  :do { /file/remove [find name=kox-servers.txt] } on-error={}
  :do {
    /tool/fetch url=$listUrl mode=https dst-path=kox-servers.txt
  } on-error={
    :put "Ne udalos skachat spisok serverov"
    :error "server list fetch failed"
  }
  :delay 1s
  :local txt ""
  :do { :set txt [/file/get [find name=kox-servers.txt] contents] } on-error={}
  :put $txt
  :put "Pereklyuchenie: :global koxServerIndex N"
  :put "                /import file-name=kox-switch.rsc"
} else={
  :if ([:typeof $idx] != "num" or $idx < 1) do={
    :put "Nomer servera s 1. Snachala posmotrite spisok bez koxServerIndex."
    :error "bad index"
  }
  :local cid [/container/find where comment="kox-shield-singbox"]
  :if ([:len $cid] = 0) do={
    :put "Kontejner kox-shield-singbox ne najden"
    :error "no container"
  }
  :put ("[*] Server #$idx")
  :do { /file/remove [find name=singbox.json] } on-error={}
  :do {
    /tool/fetch url=($cfgUrl . "&index=" . $idx) mode=https dst-path=singbox.json
  } on-error={
    :put "Ne udalos skachat konfig. Proverte nomer."
    :error "config fetch failed"
  }
  :delay 1s
  :local cfg ""
  :do { :set cfg [/file/get [find name=singbox.json] contents] } on-error={}
  :if ([:len $cfg] < 20) do={
    :put "Konfig pustoj. Proverte nomer v spiske."
    :error "empty config"
  }
  /container/stop $cid
  :delay 2s
  :do { /file/remove [find name="kox-mount/config.json"] } on-error={}
  /file/set [find name=singbox.json] name=kox-mount/config.json
  /container/start $cid
  :set koxServerIndex ""
  :put ("Gotovo. Aktivna lokaciya #$idx")
}
