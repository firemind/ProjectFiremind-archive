updateFavicon = (state) ->
  link = document.querySelector("link[rel*='icon']") || document.createElement('link')
  link.type = 'image/x-icon'
  link.rel = 'shortcut icon'
  link.href = "/favicons/"+state+".ico"
  document.getElementsByTagName('head')[0].appendChild(link)

$ ->
  $(".duel-live-view").each ->
    liveView = $(this)
    channel_conf =  { channel: "DuelQueuesChannel", id: liveView.data().dqId }
    channel_id = JSON.stringify(channel_conf)
    if (existing = App.cable.subscriptions.findAll(channel_id)).length > 0
      for sub in existing
        sub.unsubscribe()
      App.cable.subscriptions.remove(channel_id)
#      App.cable.subscriptions.reload()
    setTimeout ->
      App.cable.subscriptions.create channel_conf,
        received: (data) ->
          @updateOrInsert(data)
        connected: ->
          liveView.find(".status").html("<span class='label success'>live updating</span>")
        disconnected: ->
          liveView.find(".status").html("<span class='label alert'>disconnected</span>")


        updateOrInsert: (data) ->
          $.get(url: data.url).done (resp) ->
            existing = liveView.find(".duels").find("[data-duel-id="+(data.duel_id)+"]")
            updateFavicon(data.duel_state)
            if existing.length
              existing.remove()
              liveView.find(".duels").prepend(resp)
              populateTooltipOn(liveView.find(".duels"))
            else if liveView.data().dqAddNew?
              liveView.find(".duels").prepend(resp)
            populateTooltipOn(liveView.find(".duels"))
      500
