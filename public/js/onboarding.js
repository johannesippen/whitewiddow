var onboarding = [{
  "name":"welcome"
},{
  "name":"fb_connect"
},{
  "name":"fb_contacts"
},{
  "name":"allow_push"
},{
  "name":"allow_location"
}];

$onboarding = $('#onboarding');

var buildOnboarding = function(){
  for(i = onboarding.length-1; i >= 0; i--) {
    view = onboarding[i];

    // Indicator Bullets
    var indicator = '<div class="indicator">';
    for(step = 0; step < onboarding.length; step++){
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