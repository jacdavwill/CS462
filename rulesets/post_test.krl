ruleset post_test {
    meta {
      
    }
  
    rule post_test {
      select when post test
      pre {
        never_used = event:attrs.klog("attrs")
      }
    }
}

// ip: 192.168.1.188
// port: 3000
// channel: ckkun9ckq000axruw9s2ggili
// pico eci: ckk0moqr200014auw825n5gvs
// domain: wovyn
// type: heartbeat
// url: http://192.168.1.188:3000/sky/event/ckkun9ckq000axruw9s2ggili/eventID/post/test