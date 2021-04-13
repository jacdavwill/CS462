ruleset hello_world {
    meta {
      name "Hello World"
      description <<
  A first ruleset for the Quickstart
  >>
      author "Jacob Williams"
      shares hello
    }
     
    global {
      hello = function(obj) {
        msg = "Hello " + obj;
        msg
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
     
  }