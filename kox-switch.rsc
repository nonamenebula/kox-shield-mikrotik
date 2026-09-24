# $kox switch       - spisok lokaciy i ping
# $kox switch 4    - pereklyuchit kontejner na nomer 4
# Podpiska: :global koxSubUrl ili fajl kox-sub.url

:global kox do={
  :global koxSubUrl

  :if ($1 != "switch") do={
    :put "Komanda: \$kox switch"
    :put "         \$kox switch 4"
    :error "usage"
  }

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
  :local listUrl ($base . "/sb/" . $tok . "/servers?mode=auto&ascii=1&addr=1")
  :local cfgUrl ($base . "/sb/" . $tok . "?mode=auto&device=mikrotik&index=")

  :local wantSwitch false
  :local idx 0
  :if ([:typeof $2] = "num") do={
    :set wantSwitch true
    :set idx $2
  }
  :if ([:typeof $2] = "str" and [:len $2] > 0) do={
    :set wantSwitch true
    :set idx [:tonum $2]
  }

  :if ($wantSwitch) do={
    :if ([:typeof $idx] != "num" or $idx < 1) do={
      :put "Nomer servera s 1. Snachala: \$kox switch"
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
      /tool/fetch url=($cfgUrl . $idx) mode=https dst-path=singbox.json
    } on-error={
      :put "Ne udalos skachat konfig. Proverte nomer: \$kox switch"
      :error "config fetch failed"
    }
    :delay 1s
    :local cfg ""
    :do { :set cfg [/file/get [find name=singbox.json] contents] } on-error={}
    :if ([:len $cfg] < 20) do={
      :put "Konfig pustoj. Proverte nomer: \$kox switch"
      :error "empty config"
    }
    /container/stop $cid
    :delay 2s
    :do { /file/remove [find name="kox-mount/config.json"] } on-error={}
    /file/set [find name=singbox.json] name=kox-mount/config.json
    /container/start $cid
    :put ("Gotovo. Aktivna lokaciya #$idx")
  } else={
    :do { /file/remove [find name=kox-servers.txt] } on-error={}
    :do {
      /tool/fetch url=$listUrl mode=https dst-path=kox-servers.txt
    } on-error={
      :put "Ne udalos skachat spisok serverov"
      :error "server list fetch failed"
    }
    :delay 1s
    :local raw ""
    :do { :set raw [/file/get [find name=kox-servers.txt] contents] } on-error={}
    :local rest $raw
    :local cache ""
    :while ([:len $rest] > 0) do={
      :local nl [:find $rest "\n"]
      :local line $rest
      :if ([:typeof $nl] = "num") do={
        :set line [:pick $rest 0 $nl]
        :set rest [:pick $rest ($nl + 1) [:len $rest]]
      } else={
        :set rest ""
      }
      :if ([:len $line] > 0 and [:pick $line ([:len $line] - 1) [:len $line]] = "\r") do={
        :set line [:pick $line 0 ([:len $line] - 1)]
      }
      :if ([:len $line] > 0) do={
        :local p1 [:find $line "|"]
        :local p2 0
        :local num ""
        :local name ""
        :local ip ""
        :if ([:typeof $p1] = "num") do={
          :set num [:pick $line 0 $p1]
          :local tail [:pick $line ($p1 + 1) [:len $line]]
          :set p2 [:find $tail "|"]
          :if ([:typeof $p2] = "num") do={
            :set name [:pick $tail 0 $p2]
            :set ip [:pick $tail ($p2 + 1) [:len $tail]]
          }
        }
        :if ([:len $num] > 0 and [:len $name] > 0) do={
          :local ms "timeout"
          :local key ($ip . "=")
          :local hit [:find $cache $key]
          :if ([:len $ip] = 0) do={
            :set ms "-"
          } else={
            :if ([:typeof $hit] = "num") do={
              :local tail [:pick $cache ($hit + [:len $key]) [:len $cache]]
              :local semi [:find $tail ";"]
              :if ([:typeof $semi] = "num") do={ :set ms [:pick $tail 0 $semi] }
            } else={
              :local sum 0
              :local n 0
              :for i from=1 to=3 do={
                :do {
                  :local r [/ping address=$ip count=1 as-value]
                  :local t [:tostr ($r->"time")]
                  :if ([:len $t] = 0) do={ :set t [:tostr ($r->"avg-rtt")] }
                  :local num 0
                  :local ok false
                  :local msPos [:find $t "ms"]
                  :if ([:typeof $msPos] = "num") do={
                    :set num [:tonum [:pick $t 0 $msPos]]
                    :set ok true
                  } else={
                    :local dot [:find $t "."]
                    :if ([:typeof $dot] = "num") do={
                      :local frac [:pick $t ($dot + 1) ($dot + 4)]
                      :while ([:len $frac] < 3) do={ :set frac ($frac . "0") }
                      :set num [:tonum [:pick $frac 0 3]]
                      :set ok true
                    }
                  }
                  :if ($ok and [:typeof $num] = "num" and $num > 0) do={
                    :set sum ($sum + $num)
                    :set n ($n + 1)
                  }
                } on-error={}
              }
              :if ($n > 0) do={
                :set ms (($sum / $n) . "ms")
              } else={
                :set ms "timeout"
              }
              :set cache ($cache . $ip . "=" . $ms . ";")
            }
          }
          :local pad $name
          :while ([:len $pad] < 16) do={ :set pad ($pad . " ") }
          :put ($num . "  " . $pad . $ms)
        }
      }
    }
    :put "Pereklyuchenie: \$kox switch N"
  }
}

:global koxBoot
:if ($koxBoot = "define") do={
  :set koxBoot ""
} else={
  :global koxServerIndex
  :local n $koxServerIndex
  :set koxServerIndex ""
  :if ([:typeof $n] = "num") do={
    $kox switch $n
  } else={
    :if ([:typeof $n] = "str" and [:len $n] > 0) do={
      $kox switch $n
    } else={
      $kox switch
    }
  }
}

:do { /system/scheduler/remove [find name=kox-cli] } on-error={}
/system/scheduler/add name=kox-cli start-time=startup interval=1d \
  on-event=":global koxBoot \"define\"; /import file-name=kox-switch.rsc" \
  policy=ftp,read,write,test comment="kox switch"
