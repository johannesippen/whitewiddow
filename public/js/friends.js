var friendlist = new Array();
var social = new Social();
var FacebookContacts_loaded = false;

// loads Facebook Friends
var loadFacebookContacts = function() {
  if(!FacebookContacts_loaded) {
    var url = "/data/friends.json";
    if(window.location.host == "localhost") {
      var url = "../data/friends.json";
    }
    social.addNativeListener("getInvitedUser", function(data)
    {
      FacebookContacts_loaded = true;
      var state = "";
      for(i in data) {
      	switch(data[i].invitationState)
      	{
	      	case "pending":
	      		state = "pending";
	      	break;
	      	
	      	case "pendingByMe":
	      		state = "accept";
	      	break;
	      	
	      	default:
	      		state = "invite"; 
	      		
      	}
        if(state == "pending" || state == "accept") {
          $('.fb_friend_list').prepend('<li class="fb_friend" data-index="'+computerName(data[i].name)+'"><img src="http://graph.facebook.com/'+data[i].fbID+'/picture"><span><b>'+data[i].name+'</b><button ontouchstart="inviteFriend(\''+data[i].fbID+'\',\''+state+'\');" id="addfriends_invite" class="'+computerName(state)+'">'+buttonState(state)+'</button></span></li>');          
        } else {
          $('.fb_friend_list').append('<li class="fb_friend" data-index="'+computerName(data[i].name)+'"><img src="http://graph.facebook.com/'+data[i].fbID+'/picture"><span><b>'+data[i].name+'</b><button ontouchstart="inviteFriend(\''+data[i].fbID+'\',\''+state+'\');" id="addfriends_invite" class="'+computerName(state)+'">'+buttonState(state)+'</button></span></li>');
        }
      }
    });
    social.getInvitedUser();    
  }
};

var buttonState = function(state) {
  if(state == "invite") { state = "+"; }
  return state;
};

var computerName = function(name){
  return (name.replace(/ /g, "")).toLowerCase();
};

$('button.invite').live('mouseup touchend',function(){
  $(this).text('Pending').addClass('pending').removeClass('invite');
});

var inviteFriend = function(id, state)
{
	if(state == "invite")
	{
		social.inviteFBUser(id);	
	}
	else if(state == "accept")
	{
		social.setInvitationState(state, id);
	}
	
}

// loads the actual friendlist from backend
var loadFriends = function(user_id) {
  var url = "/data/friends.json";
  if(window.location.host == "localhost") {
    var url = "../data/friends.json";
  }
  social.addNativeListener("getWWFriendsList", function(data)
  {
    if(data.length > 6) {
      $('#friendlist_add').remove();
    }
    for(var i = 0; i <= 5; i++) {
      if(data.length > i) {
        friendlist.push(data[i]);
        addFriendtoList(data[i], i);
      } else {
        $('#friendlist').append('<li class="friend_slot"><div class="symbol"><img src="img/lock-icon-2x.png"></div></li>')          
      }
    }
    arrangeBubbles(document.querySelectorAll('#friendlist .friend'));
  });
  social.getWWFriendsList();
};

// adds a person to the friend list
var addFriendtoList = function(user, i) {
    $('<li class="friend '+user.availability+'" onclick="createInviteFor(\''+i+'\')"></li>')
      .html('<span class="name">'+user.name+'</span>')
      .prepend('<img src="https://graph.facebook.com/'+user.fbID+'/picture?width=200&height=200">')
      .appendTo($('#friendlist'));
    
    // Secondary List
    if(i == 0) {
      $('<li class="friend '+user.availability+'"></li>')
        .html('<span class="name">'+user.name+'</span>')
        .prepend('<img src="https://graph.facebook.com/'+user.fbID+'/picture?width=200&height=200">')
        .prependTo($('.attendees'));
    } else {
      $('<li class="friend '+user.availability+'"></li>')
        .html('<span class="name">'+user.name+'</span>')
        .prepend('<img src="https://graph.facebook.com/'+user.fbID+'/picture?width=200&height=200">')
        .appendTo($('#friendlist_event'));      
    }
};

// adds you to the friend list
var addMeToFriendlist = function(user) {
$('<div class="me"></div>')
  .prepend('<img src="https://graph.facebook.com/'+user.fbID+'/picture?width=200&height=200">')
  .insertBefore($('#friendlist'));
};

// shows the friends profile
var showFriendProfile = function(user_id) {
  
};

var createInviteFor = function(user_id) {
  coreLocation.addNativeListener("getLocation", _onCoreLocationReceived);
  coreLocation.getLocation();
  friend_coordinates = [friendlist[user_id].location.longitude,friendlist[user_id].location.latitude];
  if(friend_coordinates[0] == 0 || friend_coordinates[0] == undefined || friend_coordinates[1] == 0 || friend_coordinates[1] == undefined) {
    friend_coordinates = my_coordinates;
  }
  var map = document.getElementById('map');
      map.src = staticMapUrl(my_coordinates,friend_coordinates,300,180);
  
  getVenue(getMidpoint(my_coordinates,friend_coordinates),true);
}