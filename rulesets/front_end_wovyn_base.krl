ruleset front_end_wovyn_base {
    meta {
      configure using 
        sid = meta:rulesetConfig{"sid"}
        token = meta:rulesetConfig{"token"}
  
      use module twilio
        with
          SID = sid
          authToken = token
      
      provides get_threshold, get_number, set_threshold, set_number, init
      shares get_threshold, get_number
    }
  
    global {
      get_threshold = function () {
        ent:temperature_threshold
      }

      get_number = function () {
        ent:phone_number
      }

      set_threshold = defaction(threshold) {
        every {
          event:update_threshold({"threshold": threshold})
        }
      }

      set_number = defaction(number) {
        every {
          event:update_number({"number": number})
        }
      }

      init = defaction() {
        every {
          event:initialize({})
        }
      }
    }

    rule update_threshold {
      select when wovyn update_threshold
      pre {
        threshold = event:attrs{"threshold"}
      }
      if threshold then noop()
      fired {
        ent:temperature_threshold := threshold
      }
    }

    rule update_number {
      select when wovyn update_number
      pre {
        number = event:attrs{"number"}
      }
      if number then noop()
      fired {
        ent:phone_number := number
      }
    }

    rule initialize {
        select when wovyn initialize
        always {
          ent:temperature_threshold := 75
          ent:phone_number := "8019038035"
        }
    }
      
    rule process_heartbeat {
      select when wovyn heartbeat
      pre {
        msg = "received temp msg event"
        includesGenericThing = event:attrs{"genericThing"} => "YES" | "NO"
      }
      choose includesGenericThing {
        YES => send_directive(msg)
        NO => noop()
      }
      fired {
        log info "fired"
        raise wovyn event "new_temperature_reading"
          attributes {
            "temperature": {
              "tempF": event:attrs{"genericThing"}{"data"}{"temperature"}[0]{"temperatureF"},
              "tempC": event:attrs{"genericThing"}{"data"}{"temperature"}[0]{"temperatureC"}
            },
            "timestamp": event:time
          } if (includesGenericThing)
      } finally {
        log info "event received"
      }
    }
       
    rule find_high_temps {
      select when wovyn new_temperature_reading
      pre {
        temp = event:attrs{"temperature"}{"tempF"}
        tempIsHigh = (temp > ent:temperature_threshold) => "YES" | "NO"
      }
      choose tempIsHigh {
        YES => send_directive("temperature is high")
      }
      fired {
        log info <<The temp: #{temp} > #{ent:temperature_threshold} = #{tempIsHigh}>>
        raise wovyn event "threshold_violation" attributes event:attrs if (tempIsHigh == "YES")
      }
    }
  
    rule threshold_notification {
      select when wovyn threshold_violation
      pre {
        high_temp = event:attrs{"temperature"}{"tempF"}
        msg = <<Uh, oh! Detected a really high temperature (#{high_temp})!>>
      }
      twilio:sendMessage(ent:phone_number, "18159009380", msg) setting(response)
      fired {
        log info "sent warning message"
        log info response
      }
    }
  }
  