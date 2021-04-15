ruleset wovyn_base {
  meta {
    configure using 
      sid = meta:rulesetConfig{"sid"}
      token = meta:rulesetConfig{"token"}

    use module twilio
      with
        SID = sid
        authToken = token
  }

  global {
    temperature_threshold = 90
    phone_number = "8019038035"
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
      tempIsHigh = (temp > temperature_threshold) => "YES" | "NO"
    }
    choose tempIsHigh {
      YES => send_directive("temperature is high")
    }
    fired {
      log info <<The temp: #{temp} > #{temperature_threshold} = #{tempIsHigh}>>
      raise wovyn event "threshold_violation" attributes event:attrs if (tempIsHigh == "YES")
    }
  }

  rule threshold_notification {
    select when wovyn threshold_violation
    pre {
      high_temp = event:attrs{"temperature"}{"tempF"}
      msg = <<Uh, oh! Detected a really high temperature (#{high_temp})!>>
    }
    twilio:sendMessage(phone_number, "18159009380", msg) setting(response)
    fired {
      log info "sent warning message"
      log info response
    }
  }
}


// ip: 192.168.1.188 (run using windows, not linux)
// port: 3000
// channel: cklyj9kt4000gqsuwgduc44rk
// eci: cklyj6bpz0001qsuw37ql2iot
// domain: wovyn
// type: heartbeat
// url: http://192.168.1.188:3000/sky/event/cklyj9kt4000gqsuwgduc44rk/temp/wovyn/heartbeat
//ex:   http://localhost   :3000   /sky/event/ckcvuri6r0017conl4siq0q3r/1556/echo/hello

