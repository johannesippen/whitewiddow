/* Specific Action */
$('#welcome button').live('click',function(){
  hasAccessToContacts();
});
$('#allowLocation button').live('click',function(){
  allowCoreLocation();
});
$('#allowNotification button').live('click',function(){
  var notification = new PushNotification();
  notification.authorizePushNotification();
});
$('#addFriends button').live('click',function(){
  localStorage.setItem('permissions',true);
  $('body').attr('data-mode','friends');
//  loadFacebookContacts();
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