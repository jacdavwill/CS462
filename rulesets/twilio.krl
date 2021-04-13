ruleset twilio {
  meta {
    name "twilio module"
    description <<
      An module for twilio
    >>
    configure using
      SID = ""
      authToken = ""
    provides sendMessage, messages
  }
  global {
    short_base_url = "https://api.twilio.com"
    base_url = "https://api.twilio.com/2010-04-01/Accounts"

    sendMessage = defaction(to, from, msg) {
      body = {"To":to,"From":from,"Body":msg}.klog()
      token = math:base64encode(<<#{SID}:#{authToken}>>)
      header = {"Authorization": <<Basic #{token}>>}
      every {
        http:post(<<#{base_url}/#{SID}/Messages.json>>, form=body, headers=header) setting(response)
      }
      return response
    }

    messages = defaction(pageSize, nextPageUrl, sender, destination) {
      token = math:base64encode(<<#{SID}:#{authToken}>>)
      header = {"Authorization": <<Basic #{token}>>}
      includesNPU = nextPageUrl => "YES" | "NO"
      includesPageSize = pageSize => true | false
      includesSender = sender => true | false
      includesDestination = destination => true | false
      
      qs = ((includesPageSize && includesSender && includesDestination) => <<?PageSize=#{pageSize}&To=#{destination}&From=#{sender}>> | ((includesSender && includesDestination) => <<?To=#{destination}&From=#{sender}>> | (includesPageSize => <<?PageSize=#{pageSize}>> | ((includesDestination => <<?To=#{destination}>> | (includesSender => <<?From=#{sender}>> | "")))))).klog("qs expression")

      choose includesNPU {
        NO => http:get(<<#{base_url}/#{SID}/Messages.json#{qs}>>.klog("Message Query"), headers=header) setting(response)
        YES => http:get(<<#{short_base_url}#{nextPageUrl}>>.klog("Next Message Query"), headers=header) setting(response)
      }
      
      return response
    }
  }
}