$ ->
  $("[data-reveal-ajax]").on "click", (ev)->
    el = $(ev.target)
    if el.data('reveal-id')
      modal = $("#"+el.data('reveal-id'))
    else
      modal = $('#genericModal')
    if el.data('reveal-ajax') == true
      url = el.attr('href')
    else
      url = el.data('reveal-ajax')
    $.ajax(url).done (resp)->
      modal.html(resp).foundation('open')
    return false
