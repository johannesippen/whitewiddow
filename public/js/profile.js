var loadProfile = function(user_id) {
  var url = "../data/profile.json";
  $.getJSON(url,function(data){
    showMyProfile(data);
  });
};

var showMyProfile = function(user) {
  // TODO: Add all relevant user info to the profile page
  $('#profile').append('<h2>You are '+user.name.first+'</h2>');
  $('#profile').append('<p><img src="'+user.picture+'"></p>');
  $('#profile').append('<p>Status: '+user.status.description+'</p>');
};