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
  var seed = "1234567890"; // loads different people
  for(i = 0; i < amount; i++) {
    $.getJSON('http://randomuser.me/g/?seed='+seed[i],function(data){
      addFriendtoList(data.user);
    });
  };
}

// adds a person to the friend list
var addFriendtoList = function(user) {
    $('<li></li>')
      .text(user.name.first)
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