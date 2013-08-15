var init = function(){
  // Create Views
  for(i in views) {
    $('<section></section>')
    .attr('id',views[i].name)
    .attr('class',views[i].name)
    .append('<h2>'+views[i].name+'</h2>')
    .append(views[i].html)
    .appendTo($('body'));
  }

  // Create Onboarding
  $onboarding = $('#'+views[1].name);
  if(firstSession) {
    buildOnboarding();
  } else {
    $onboarding.remove();
    loadRandomFriends(7);
  }
};

var buildOnboarding = function(){
  for(i = views[1].views.length-1; i >= 0; i--) {
    view = views[1].views[i];

    // Indicator Bullets
    var indicator = '<div class="indicator">';
    for(step = 0; step < views[1].views.length; step++){
      if(i == step) {
        indicator += '<b>&bull;</b>';
      } else {
        indicator += '&bull;'
      }
    }
    indicator += '</div>';

    $('<div></div>')
    .attr('id',view.name)
    .attr('class',view.name+' onboarding_step')
    .append('<p>'+view.name+'</p>')
    .append(indicator)
    .on('click',function(){
      $(this).remove();
    })
    .appendTo($onboarding);
  }
};