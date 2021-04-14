ruleset temperature_store {
    meta {
      name "termperature store module"

      provides temperatures, threshold_violations, inrange_temperatures
      shares temperatures, threshold_violations, inrange_temperatures
    }

    global {
        temperatures = function() {
            ent:stored_temps
        }
        threshold_violations = function () {
            ent:stored_violations
        }
        inrange_temperatures = function () {
            ent:stored_temps.difference(ent:stored_violations)
        }
    }

    rule collect_temperatures {
        select when wovyn new_temperature_reading
        

        always {
            log info event:attrs
            ent:stored_temps := ent:stored_temps.defaultsTo([]).append({"temperature": event:attrs{"temperature"}{"tempF"}, "timestamp": event:attrs{"timestamp"}})
        }
    }

    rule collect_threshold_violations {
        select when wovyn threshold_violation

        always {
            ent:stored_violations := ent:stored_violations.defaultsTo([]).append({"temperature": event:attrs{"temperature"}{"tempF"}, "timestamp": event:attrs{"timestamp"}})
        }
    }

    rule clear_temeratures {
        select when sensor reading_reset


        always {
            clear ent:stored_temps
            clear ent:stored_violations
        }
    }
  }