$('#status_free').live('click',function(){
  $('body').attr('data-status','free');
});
$('#status_busy').live('click',function(){
  $('body').attr('data-status','busy');
});