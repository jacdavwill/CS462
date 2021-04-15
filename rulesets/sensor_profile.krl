ruleset sensor_profile {
    meta {
        configure using 
            SID = meta:rulesetConfig{"sid"}
            TOKEN = meta:rulesetConfig{"token"}

        use module front_end_wovyn_base alias wovyn
            with
                sid = SID
                token = TOKEN

        provides profile
        shares profile
    }

    global {
        profile = function() {
            ent:profile
        }
    }

    rule update_profile {
        select when sensor profile_updated
        pre {
            name = event:attrs{"name"}
            location = event:attrs{"location"}
            threshold = event:attrs{"threshold"}
            number = event:attrs{"number"}
        }
        noop()
        fired {
            ent:profile := {"name": name, "location": location, "threshold": threshold, "number": number}
            raise wovyn event "update_threshold" attributes {"threshold": threshold} if threshold
            raise wovyn event "update_number" attributes {"number": number} if number
        }
    }
  }