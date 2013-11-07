$('#status_free').live('mouseup touchend',function(){
  $('body').attr('data-status','free');
});
$('#status_busy').live('mouseup touchend',function(){
  $('body').attr('data-status','busy');
});