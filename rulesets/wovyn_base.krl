ruleset wovyn_base {
  meta {
    
  }

  global {
    termperature_threshold = 50
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
        }
    } finally {
      log info "event received"
    }
  }
     
  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      temp = event:attrs{"temperature"}
      tempIsHigh = (temp > termperature_threshold) => "YES" | "NO"
    }
    choose tempIsHigh {
      YES => send_directive("temperature is high")
      NO => noop()
    }
    fired {
      raise wovyn event "threshold_violation" attributes event:attrs
    }
  }

  rule threshold_notification {
    select when wovyn threshold_violation
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

