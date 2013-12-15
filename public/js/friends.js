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
      
        $('.fb_friend_list').append('<li class="fb_friend" data-index="'+data[i].name+'"><img src="http://graph.facebook.com/'+data[i].fbID+'/picture"><span>'+data[i].name+'</span><button ontouchstart="inviteFriend(\''+data[i].fbID+'\',\''+state+'\');" id="addfriends_invite">'+state+'</button></li>');
      }
    });
    social.getInvitedUser();    
  }
};

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
	  for(i in data) {
      friendlist.push(data[i]);
      addFriendtoList(data[i], i);
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
    $('<li class="me"></li>')
      .prepend('<img src="https://graph.facebook.com/'+user.fbID+'/picture?width=200&height=200">')
      .appendTo($('#friendlist'));
      
      $('<li class="me"></li>')
        .prepend('<img src="https://graph.facebook.com/'+user.fbID+'/picture?width=200&height=200">')
        .appendTo($('.attendees'));
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