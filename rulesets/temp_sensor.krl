ruleset temp_sensor {
    meta {
      name "temp_sensor"
      use module wovyn_base
      shares hello
    }
     
    global {
      hello = function(obj) {
        msg = "Hello " + obj;
        msg
      }

      install_request = defaction(rid) {
        ruleset = ctx:rulesets.filter(function(rs) {rs{"rid"}==rid})
        needed = (ruleset.length() == 0) => "YES" | "NO"
        choose needed {
          YES => event:send({
            "eci": meta:eci,
            "domain": "sensor",
            "type": "ruleset_install",
            "attrs": {
              "absoluteURL": meta:rulesetURI,
              "rid": rid
            }
          })
          NO => noop()
        }
      }
    }
     
    rule hello_world {
      select when echo hello
      send_directive("say", {"something": "Hello World"})
    }

    rule hello_monkey {
      select when echo monkey
      pre {
        name = event:attrs{"name"} => event:attrs{"name"} | "Monkey"
      }
      send_directive("Hello " + name.klog("The name sent is " + name))
    }

    rule create_channel {
      select when sensor ruleset_install
        where event:attr("rids") >< meta:rid
      temp_sensor:create_channel(["temp_sensor", "hello"], eventPolicy, queryPolicy)
        setting(channel)
      fired {
        ent:channel := channel
      }
    }
}