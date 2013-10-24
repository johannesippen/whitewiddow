var arrangeBubbles = function(elems){
  return false;
  var increase = Math.PI * 2 / elems.length;
  var x = 0, y = 0, angle = Math.round(Math.random()*180);

  for (var i = 0; i < elems.length; i++) {
      var elem = elems[i];
      // modify to change the radius and position of a circle
      x = 100 * Math.cos(angle) + 160;
      y = 100 * Math.sin(angle) + 160;
      elem.style.position = 'absolute';
      elem.style.left = x + 'px';
      elem.style.top = y + 'px';
      //need to work this part out
      var rot = 90 + (i * (360 / elems.length));
      angle += increase;
  }
};

$('.invite_confirm button').on('click',function(){
  $('body').attr('data-mode','friends');
})