ruleset manage_sensors {
    meta {
        configure using 
            sid = meta:rulesetConfig{"sid"}
            token = meta:rulesetConfig{"token"}
        
        use module io.picolabs.wrangler alias wrangler
  
    //   use module twilio
    //     with
    //       SID = sid
    //       authToken = token
    }
  
    global {
        childColor = "#ff69b4"
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
        }
        always {
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
        if newChildId.klog("found child") 
            then event:send(
                { 
                    "eci": newEci.get("eci"), 
                    "eid": "install-ruleset",
                    "domain": "wrangler", "type": "install_ruleset_request",
                    "attrs": {
                        "absoluteURL": meta:rulesetURI,
                        "rid": "sensor",
                        "config": {},
                        "sensorId": newChildId
                    }
                }
              )
        fired {
            ent:sensors{newChildId} := newEci
        }
    }
  }
  