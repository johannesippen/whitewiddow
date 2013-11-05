$(function(){
  /* Friendmode */
  $('#friends .friend').live('click',function(){
    $('body').attr('data-mode','invite');
  });
  $('#venue .back').live('click',function(){
    $('body').attr('data-mode','invite');
  });
  $('#venue.event .back').live('click',function(){
    $('body').attr('data-mode','event');
    $('#venue').removeClass('event');
  });
  /* Invitemode */
  $('#invite .back').live('click',function(){
    $('body').attr('data-mode','friends');
  });
  /* Add Friends */
  $('#addfriends header button').live('touchend click',function(){
    $('body').attr('data-mode','friends');
  });
  /* Add Friends */
  $('#friendlist_add').live('touchend mouseup',function(){
    $('body').attr('data-mode','addfriends');
  });
  /* Friend-Eventmode */
  $('#invite .invite_confirm button').live('click',function(){
    alert('Your friend has been invited. Let the waiting begin!');
    $('body').attr('data-mode','event');
  });
  /* Friend-Eventmode */
  $('#event .invite_confirm button').live('click',function(){
    $('body').attr('data-mode','received');
  });
  /* Venuemode */
  $('#invite .invite_venue').live('click',function(){
    $('body').attr('data-mode','venue');
  });
  $('#event .invite_venue').live('click',function(){
    $('#venue').addClass('event');
    $('body').attr('data-mode','venue');
  });
  /* Startup */  
  if(localStorage['permissions']=='true') {
    $('body').attr('data-mode','friends');    
  } else {
    $('body').attr('data-mode','permissions');    
  }
});

