$(function(){
  scope = $("body");
  scope.on('click', '.add-sideboard-out', function(e){
    e.preventDefault();
    var cardTemplate = $("#inlineSideboardAddOut").html();
    var template = cardTemplate.format($(e.target).data().archetypeid);
    $(e.target).parent("td").append(template);
  });
  scope.on('click', '.add-sideboard-in', function(e){
    e.preventDefault();
    var cardTemplate = $("#inlineSideboardAddIn").html();
    var template = cardTemplate.format($(e.target).data().archetypeid);
    var p = $(e.target).parent("td");
    var el = p.append(template);
    var input = el.find('#auto-completable-cardname').last();
    input.autocomplete({
      source: input.data('autocomplete-source')
    });
  });
  scope.on('click', '.add-suggestion-link', function(e){
    e.preventDefault();
    var form = $(this).parent();
    form.submit();
  });
});

String.prototype.format = function() {
  var args = arguments;
  return this.replace(/{(\d+)}/g, function(match, number) {
    return typeof args[number] != 'undefined'? args[number]: match;
  });
};

function populateMulliganTooltips(){
  $( '.mulligan-hand-with-tooltip[data-url]' ).qtip({
    style: {
      width: 1000,
      height: 680,
      classes: 'dealt-hand-tooltip'
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
}
$(function(){
  populateMulliganTooltips();
  $('select#meta').on('change', function () {
    var val = $(this).val(); // get selected value
    var base = (window.location+'').split("?")[0];
    if(val){
      window.location = base+'?meta_id='+val;
    }else{
      window.location = base;
    }
    return false;
  });
  $(".select2").select2({})
});
