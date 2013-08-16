var init = function(){
  // Create Onboarding
  $onboarding = $('#'+views[1].name);
  if(firstSession) {
    buildOnboarding();
  } else {
    $onboarding.remove();
    loadRandomFriends(7);
  }
};

var buildApp = function(){
  // Create Views
  for(i in views) {
    $('<section></section>')
    .attr('id',views[i].name)
    .attr('class',views[i].name)
    .append('<h2>'+views[i].name+'</h2>')
    .append(views[i].html)
    .appendTo($('body'));
  }
}