ruleset practice {
    meta {
      
      shares __testing, entry, getDeckId
  
      configure using
        SID = ""
        authToken = ""
      
      use module twilio
      with
        SID = SID
        authToken = authToken
    }
     
    global {
      __testing = {
        "queries": [
            { "name": "__testing" },
            { "name": "entry", "args": ["key"] },
            { "name": "getDeckId", "args":[] }
        ],
        "events": [
            { "domain": "msg", "type": "send", "attrs": ["to", "from", "body"] }
        ]
      }
      truthy = "truthy"
      falsy = "false"
      entry = function(key){
          {
              "key": key,
              "key.isnull()": key.isnull(),
              "key => truthy | falsy": key => truthy | falsy
          }
      }
      getDeckId = function() {
        http:get("https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1"){"content"}
          .decode().get("deck_id")
      }
    }
     
    rule send {
      select when msg send
      pre {
        to = event:attrs{"to"}
        from = event:attrs{"from"}
        msg = event:attrs{"body"}
        response = twilio:sendSMS(to, from, msg)
      }
      send_directive(response)
    }
     
  }