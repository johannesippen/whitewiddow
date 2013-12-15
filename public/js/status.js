$('#status_free').live('mouseup touchend',function(){
  $('body').attr('data-status','free');
  $('#status_busy').text('Set status to busy');
});
$('#status_busy').live('mouseup touchend',function(){
  $('body').attr('data-status','busy');
  $('#status_free').text('Set status to free');
});