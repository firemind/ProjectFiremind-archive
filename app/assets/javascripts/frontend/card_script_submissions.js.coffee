# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#card_script_submission_card_name').autocomplete
    source: $('#card_script_submission_card_name').data('autocomplete-source')
