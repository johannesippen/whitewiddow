var friendlist = new Array();

// loads the actual friendlist from backend
var loadFriendlist = function(user_id) {
  var url = "../data/friends.json";
  $.getJSON(url,function(data){
    friendlist = data;
    showFriendlist();
  });
};

// loads an "amount" of random users and puts them into friend list
var loadRandomFriends = function(amount) {
  var seed = "012345678"; // loads different people
  for(i = 0; i < amount; i++) {
    $.getJSON('http://randomuser.me/g/?seed='+seed[i],function(data){
      data.user.location = {
        "longitude": 52+Math.random(),
        "latitude": 14+Math.random()
      };
      data.user.status = {
        "description":"free"
      };
      friendlist.push(data.user);
      addFriendtoList(data.user);
      // TODO: put this in a better callback function
      arrangeBubbles(document.getElementsByClassName('friend'));
    });
  };
}

// adds a person to the friend list
var addFriendtoList = function(user) {
    $('<li class="friend" onclick="createInviteFor('+user.seed+')"></li>')
      .html('<span class="name">'+user.name.first+'</span>')
      .prepend('<img src="'+user.picture+'">')
      .appendTo($('#friendlist'));
};

// adds you to the friend list
var addMeToFriendlist = function(user) {
    $('<li class="me"></li>')
      .prepend('<img src="'+user.picture+'">')
      .appendTo($('#friendlist'));
};

// FIXME: old code for generating the friend list
var showFriendlist = function(user_id) {
  for(i in friendlist) {
    $('<li></li>')
      .text(friendlist[i].name)
      .prepend('<img src="'+friendlist[i].avatar+'">')
      .appendTo($('#friendlist'));
  }
};

// shows the friends profile
var showFriendProfile = function(user_id) {
  
};

var createInviteFor = function(user_id) {
  console.log(friendlist[user_id]);
  friend_ll = [friendlist[user_id].location.longitude,friendlist[user_id].location.latitude];
  getVenue(getMidpoint(friend_ll,my_coordinates),true);
  var map = document.getElementById('map');
      map.src = staticMapUrl(my_coordinates,friend_ll,300,180);
}