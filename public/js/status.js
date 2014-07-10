//var statusSocial = new Social();

$('#status_free').live('mouseup touchend',function(){
  $('body').attr('data-status','free');
  $('#status_busy').text('Set status to busy');
  social.saveCurrentState("free");
});
$('#status_busy').live('mouseup touchend',function(){
  $('body').attr('data-status','busy');
  $('#status_free').text('Set status to free');
  social.saveCurrentState("busy");
});

var refreshDashboard = function() {
  window.location.reload();
};