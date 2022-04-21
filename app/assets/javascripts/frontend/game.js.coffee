# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  manaSymbolMappings = {
    G: 'green',
    U: 'blue', 
    B: 'black', 
    R: 'red', 
    W: 'white', 
    X: 'x',
    GW: 'green-white', 
    WB: 'white-black', 
    RW: 'red-white'
  }
  populateManaSymbols = (text) ->
    text = text.replace /<([A-Za-z0-9 -']+)\~(\d+)>/g, (match, cardname) -> 
      cardId = cardNameMappings[cardname]
      return '<a class="card-with-tooltip" data-url="/cards/'+cardId+'/tooltip" href="/cards/'+cardId+'" data-hasqtip="true">'+cardname+'</a>'
    for mapping in Object.keys(manaSymbolMappings)
      text = text.replace(new RegExp("{"+mapping+"}","g"), "<span class='mana-"+manaSymbolMappings[mapping]+"'>&nbsp</span>")
    for i in [0..20]
      text = text.replace(new RegExp("\\{"+i+"\\}","g"), "<span class='colorless-"+i+"'>&nbsp</span>")
    return text
  if (log = $('.gamelog')).length > 0
    phaseTemplate = $("#gamePhaseTemplate").html()
    actionTemplate = $("#gameActionTemplate").html()
    optionTemplate = $("#gameOptionTemplate").html()
    winner = log.data().winner;
    last_life= {
    }
    $.get(log.data().url).success (data) ->
      log.append(data.system)
      count = 0
      for turn in data.turns
        playerClass = if turn.active_player == winner then 'winner' else 'loser'
        turnDiv = $("<div class='turn "+playerClass+"'></div>")
        turnDiv.append("Turn "+turn.number)
        phaseAccordion = $(phaseTemplate.format());
        for phase in Object.keys(turn.phases)
          for phasePart in turn.phases[phase]
            count+=1
            options = phasePart.options
            actions = phasePart.actions
            life = phasePart.life_active_player
            performedActions = actions.length > 0
            cls = "secondary"
            if last_life[turn.active_player]
              if last_life[turn.active_player] > life
                cls = "alert"
                last_life[turn.active_player] = life
            else
              last_life[turn.active_player] = life
            playerCls = if turn.active_player == winner then 'winner' else 'loser'
            actionLi = $(actionTemplate.format(count, phase+" (options: "+options.length+", actions: "+actions.length+")", cls, data.players[phasePart.active_player].full, life, playerCls));
            if actions.length > 0
              actionLi.addClass("is-active")
            actionContent = actionLi.find(".accordion-content")
            choice = options.filter (obj) -> 
              return obj[0] == "*"
            choice = choice[0]
            if choice? 
              optionDiv = $(optionTemplate.format(count, choice.split("] ")[1]));
              optionContent = optionDiv.find("ul.options")
              for option in options
                optionLi = $("<li></li>")
                optionLi.append(populateManaSymbols(option))
                optionContent.append(optionLi)
            actionContent.append(optionDiv)
            for action in actions
              actionDiv = $("<div></div>")
              actionDiv.append(populateManaSymbols(action.text))
              actionContent.append(actionDiv)
            phaseAccordion.append(actionLi)
          turnDiv.append(phaseAccordion)
        log.append(turnDiv)
      populateTooltips()
      $(document).foundation()
