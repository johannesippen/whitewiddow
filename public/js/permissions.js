/* Specific Action */
$('#welcome button').live('click',function(){
  hasAccessToContacts();
});
$('#allowLocation button').live('click',function(){
  allowCoreLocation();
});
$('#allowNotification button').live('click',function(){
  // TODO: Placeholder
  confirm('Whitewidow Would Like to Send You Push Notifications')
});
$('#addFriends button').live('click',function(){
  localStorage.setItem('permissions',true);
  $('body').attr('data-mode','addfriends');
});
/* Next Slide */
$('.permission_action button').live('click',function(){
  $(this).parents('.permission').remove();
});
/* Sort Permissions */
$(function(){
  $('#permissions .permission').each(function(){
    $(this).prependTo('#permissions');
  });
});