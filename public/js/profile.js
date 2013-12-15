var loadProfile = function(user_id) {
	  var url = "../data/profile.json";
	  social.getUser();
	  social.addNativeListener("getUserData",function(data)
	  {
	  		showMyProfile(data);
	  });
};

var showMyProfile = function(user) {
  addMeToFriendlist(user);
};