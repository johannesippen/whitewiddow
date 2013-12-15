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
      for(i in data) {
        $('.fb_friend_list').append('<li class="fb_friend" data-index="'+user.name+'"><img src="http://graph.facebook.com/'+user.fbID+'/picture"><span>'+user.name+'</span><button id="addfriends_invite">Invite</button></li>');
      }
    });
    social.getInvitedUser();    
  }
};

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
  alert(friendlist[user_id].name);
  friend_coordinates = [friendlist[user_id].location.longitude,friendlist[user_id].location.latitude];
  var map = document.getElementById('map');
      map.src = staticMapUrl(my_coordinates,friend_coordinates,300,180);
      
  getVenue(getMidpoint(my_coordinates,friend_coordinates),true);
}