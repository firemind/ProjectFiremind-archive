function populateTooltips(){
  populateTooltipOn($(document))
}
function populateTooltipOn(scope){
  var links = scope.find( '.card-with-tooltip[data-url]' );
  links.qtip({
    style: {
      classes: 'card-tooltip',
      width: 480,
      height: 690
    },
    content: {
      text: function(event, api) {
        $.ajax({
          url: this.data('url') // Use data-url attribute for the URL
        })
        .then(function(content) {
          // Set the tooltip content upon successful retrieval
          api.set('content.text', content);
        }, function(xhr, status, error) {
          // Upon failure... set the tooltip content to the status and error value
          api.set('content.text', status + ': ' + error);
        });

        return 'Loading...' // Set some initial text
      }
    },
    position: {
      viewport: $(window),
      adjust: {
          method: 'shift'
      }
    }
  });
  links.click(function(e){
      $(e.target).qtip('hide')
  })
}

$(function(){
  populateTooltips();
  if ($('#duel_format_id')) {
    decks = $('#duel_deck_list1_id').html();
    filter_selected_format(decks);
    $('#duel_format_id').change(function(){
      filter_selected_format(decks);
    });
  }

  var $eventSelect = $(".deck_list_select").select2({
    ajax: {
      url: "/duels/search_decks.json",
      dataType: 'json',
      delay: 250,
      data: function (params) {
        return {
          query: params.term, // search term
          format_id: $("#duel_format_id").val(),
          page: params.page
        };
      },
      processResults: function (data, page) {
        // parse the results into the format expected by Select2.
        // since we are using custom formatting functions we do not need to
        // alter the remote JSON data
        return {
          results: data.decks
        };
      },
      cache: true
    },
    escapeMarkup: function (markup) { return markup; }, // let our custom formatter work
    minimumInputLength: 4,
    templateResult: formatRepo, // omitted for brevity, see the source of this page
    templateSelection: formatRepoSelection // omitted for brevity, see the source of this page
  });
  $("#duel_format_id").on("change", function (e) {
    $(".deck_list_select").val(null).trigger("change").trigger("select2:select");
  });
  $(".deck_list_select").on("select2:select", function (e) {
    var id = e.currentTarget.value
    if(id == ""){
      $("#deck_list"+(e.target.id == "duel_deck_list1_id" ? '1' : '2' )+"_box").html("")
    }else{
      $.get("/deck_lists/"+id+"/list").done(function(data){
        var el = $("#deck_list"+(e.target.id == "duel_deck_list1_id" ? '1' : '2' )+"_box");
        el.html(data)
        populateTooltipOn(el);
      });
    }
  });
});

function formatRepo (deck) {
  if (deck.loading) return deck.text;

  var markup = '<div class="row deck-search-preview">' +
  '<div class="large-3 columns">' +
  '<img src="' + deck.avatar + '" style="max-width: 100%" />' +
  '</div>' +
  '<div clas="large-9 columns">' +
  '<b>' + deck.title + '</b>';

  if (deck.list_excerpt) {
    markup += '<div>' + deck.list_excerpt + '</div>';
  }

  markup += '</div></div>';
  markup = $(markup);
  populateTooltipOn(markup);
  return markup;
}

function formatRepoSelection (repo) {
  return repo.title || repo.text;
}


function filter_selected_format(decks){
  selected = $('#duel_format_id :selected').text();
  escaped_selected = selected.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1');
  options = $(decks).filter("optgroup[label='"+escaped_selected+"']").html();
  $('#duel_deck_list1_id').html(options);
  $('#duel_deck_list1_id').parent().parent().show();
  $('#duel_deck_list2_id').html(options);
  $('#duel_deck_list2_id').parent().parent().show();
}
