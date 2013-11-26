var friendlist = new Array();
var social = new Social();


// loads the actual friendlist from backend
var loadFriends = function(user_id) {
	alert("loadFriends");
  var url = "/data/friends.json";
  if(window.location.host == "localhost") {
    var url = "../data/friends.json";
  }
  social.addNativeListener("getWWFriendsList", function(data)
  {
	  for(i in data) {
      data[i].location = {
        "longitude": 52+Math.random()*0.1167+0.4166, // Min: .4166, Max: .5333
        "latitude": 13+Math.random()*0.4+0.1666 // Min: .5666, Max: .1666
      };
      friendlist.push(data[i]);
      addFriendtoList(data[i], i);
    }
    arrangeBubbles(document.querySelectorAll('#friendlist .friend'));
  });
  social.getWWFriendsList();
  
  /*$.getJSON(url,function(data){
    for(i in data) {
      data[i].location = {
        "longitude": 52+Math.random()*0.1167+0.4166, // Min: .4166, Max: .5333
        "latitude": 13+Math.random()*0.4+0.1666 // Min: .5666, Max: .1666
      };
      friendlist.push(data[i]);
      addFriendtoList(data[i], i);
    }
    arrangeBubbles(document.querySelectorAll('#friendlist .friend'));
  });*/
};

// loads an "amount" of random users and puts them into friend list
var loadRandomFriends = function(amount) {
  var seed = "012345678"; // loads different people
  for(i = 0; i < amount; i++) {
    $.getJSON('http://randomuser.me/g/?seed='+seed[i],function(data){
      data = data.results[0];
      data.user.location = {
        "longitude": 52+Math.random()*0.1167+0.4166, // Min: .4166, Max: .5333
        "latitude": 13+Math.random()*0.4+0.1666 // Min: .5666, Max: .1666
      };
      data.user.status = {
        "description":"free"
      };
      friendlist.push(data.user);
      addFriendtoList(data.user, i);
      // TODO: put this in a better callback function
      arrangeBubbles(document.getElementsByClassName('friend'));
    });
  };
}

// adds a person to the friend list
var addFriendtoList = function(user, i) {
    $('<li class="friend '+user.availability+'" onclick="createInviteFor('+user._id+')"></li>')
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
      .prepend('<img src="'+user.picture+'">')
      .appendTo($('#friendlist'));
      
      $('<li class="me"></li>')
        .prepend('<img src="'+user.picture+'">')
        .appendTo($('.attendees'));
};

// shows the friends profile
var showFriendProfile = function(user_id) {
  
};

var createInviteFor = function(user_id) {
  friend_coordinates = [friendlist[user_id].location.longitude,friendlist[user_id].location.latitude];
  var map = document.getElementById('map');
      map.src = staticMapUrl(my_coordinates,friend_coordinates,300,180);
      
  getVenue(getMidpoint(my_coordinates,friend_coordinates),true);
    

}