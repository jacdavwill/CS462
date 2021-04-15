ruleset manage_sensors {
    meta {
        configure using 
            sid = meta:rulesetConfig{"sid"}
            token = meta:rulesetConfig{"token"}
        
        use module io.picolabs.wrangler alias wrangler
  
        use module twilio
            with
                SID = sid
                authToken = token
        
        provides sensors
        shares sensors
    }
  
    global {
        childColor = "#ff69b4"
        defaultThreshold = 80
        base_url = "http://localhost:3000/c/"
        post_url = "/query/temperature_store/temperatures"

        sensors = function(id) {
            ent:sensors{id}
        }

        getTemps = function() {
            event:get_temps()
        }
    }

    rule get_temps {
        select when sonsors get_temps
        foreach ent:sensors setting (x)
        pre {
            eci = x{"eci"}
        }
        
        every {
            http:get(<<#{base_url}#{eci}#{post_url}>>) setting(response)
        }

        fired {
            ent:resp := ent:resp.defaultsTo([]).append(response)
            log info ent:resp
        }
    }

    rule initialize_sensors {
        select when sensors needs_initialization
        always {
            ent:sensors := {}
        }
    }
      
    rule new_sensor_created {
        select when sensor new_sensor
        pre {
            newId = wrangler:children().length() + 1
            id_dne = newId >< ent:sensors.map(function(v, k) {k})
        }
        if id_dne then noop()
        fired {
            raise wrangler event "new_child_request"
                attributes { "name": <<child-#{newId}>>, "backgroundColor": childColor, "childId": newId }
        }
    }

    rule new_child_created {
        select when wrangler new_child_created
        pre {
            newEci = { "eci": event:attrs{"eci"} }
            newChildId = event:attrs{"childId"}
        }
        if newChildId.klog("found child") then
            every {
                event:send(
                    { 
                        "eci": newEci.get("eci"), 
                        "eid": "install-ruleset",
                        "domain": "wrangler", "type": "install_ruleset_request",
                        "attrs": {
                            "absoluteURL": "temperature_store",
                            "rid": "sensor",
                            "config": {},
                            "sensorId": newChildId
                        }
                    }
                )
                event:send(
                    { 
                        "eci": newEci.get("eci"), 
                        "eid": "install-ruleset",
                        "domain": "wrangler", "type": "install_ruleset_request",
                        "attrs": {
                            "absoluteURL": "wovyn_base",
                            "rid": "sensor",
                            "config": {},
                            "sensorId": newChildId
                        }
                    }
                )
                event:send(
                    { 
                        "eci": newEci.get("eci"), 
                        "eid": "install-ruleset",
                        "domain": "wrangler", "type": "install_ruleset_request",
                        "attrs": {
                            "absoluteURL": "sensor_profile",
                            "rid": "sensor",
                            "config": {},
                            "sensorId": newChildId
                        }
                    }
                )
                event:send(
                    { 
                        "eci": newEci.get("eci"), 
                        "eid": "install-ruleset",
                        "domain": "wrangler", "type": "install_ruleset_request",
                        "attrs": {
                            "absoluteURL": "io.picolabs.wovyn.emitter",
                            "rid": "sensor",
                            "config": {},
                            "sensorId": newChildId
                        }
                    }
                )
            } 
        fired {
            ent:sensors{newChildId} := newEci
            raise sensor event "profile_updated" attributes {"name": event:attrs{"name"}, "threshold": defaultThreshold, "location": "location", "number": "number"}
        }
    }

    rule delete_child {
        select when sensor uneeded_sensor
        pre {
            id = event:attrs{"id"}
        }
        if id then noop()
        fired {
            ent:sensors := ent:sensors.delete([id])
            raise wrangler event "child_deletion" attributes {
                "name": <<child-#{id}>>,
                "co_id": "sensor"
            }
        }
    }
}
  