$ ->
  $('.card_view_link').on "click", (el)->
    modal = $('#decklistModal')
    $.ajax('/deck_lists/'+el.target.dataset.decklistId+'/show_cards').done (resp)->
      modal.html(resp).foundation('open')
    return false
