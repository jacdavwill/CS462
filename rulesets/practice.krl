ruleset practice {
  meta {
    shares entry, getDeckId

    configure using 
      sid = meta:rulesetConfig{"sid"}
      token = meta:rulesetConfig{"token"}

    use module twilio
      with
        SID = sid
        authToken = token
  }
   
  global {
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
      to = event:attrs{"to"}.klog() => event:attrs{"to"} | "8019038035"
      fromNum = event:attrs{"from"}.klog() => event:attrs{"from"} | "8159009380"
      msg = event:attrs{"body"}.klog() => event:attrs{"body"} | "this is a message"
    }
    twilio:sendMessage(to, fromNum, msg) setting(response)
    fired {
      log info response
    }
  }
   
  rule messages {
    select when msg get
    pre {
      pageSize = event:attrs{"pageSize"}
      nextPageURL = event:attrs{"nextPageURL"}
      sender = event:attrs{"sender"}
      destination = event:attrs{"destination"}
    }

    every {
      twilio:messages(pageSize, nextPageURL, sender, destination) setting(response)
      send_directive(response)
    }
    
    fired {
      log info response
    }
  }
}