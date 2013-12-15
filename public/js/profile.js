var loadProfile = function(user_id) {
	  var url = "../data/profile.json";
	  social.getUser();
	  social.addNativeListener("getUserData",function(data)
	  {
	  		showMyProfile(data);
	  		loadFriends(7);
	  });
};

var showMyProfile = function(user) {
  addMeToFriendlist(user);
};