// Fund out and return what time of the day we are having. Useful for making decisions about where to go
var daytime = new Array();
    daytime['latenight'] = 360;
    daytime['morning'] = 690;
    daytime['noon'] = 870;
    daytime['afternoon'] = 1080;
    daytime['evening'] = 1320;
    daytime['night'] = 1440;
    
// Find in Foursquare categories according to daytime
var activity = new Array();
    activity['latenight'] = "4bf58dd8d48988d11f941735"; // Nightclub
    activity['morning'] = "4bf58dd8d48988d143941735,4bf58dd8d48988d16a941735,4bf58dd8d48988d1e0931735,4bf58dd8d48988d16d941735"; // Café, Coffee Shop, Breakfast Spot, 
    activity['noon'] = "4d4b7105d754a06374d81259"; // Food
    activity['afternoon'] = "4bf58dd8d48988d1e0931735,4bf58dd8d48988d16d941735"; // Café, Coffee Shop
    activity['evening'] = "4d4b7105d754a06374d81259,4bf58dd8d48988d116941735"; // Food, Bar
    activity['night'] = "4d4b7105d754a06376d81259"; // Nightlife

var getDaytime = function(){
  now = new Date();
  day_minutes = now.getHours()*60+now.getMinutes();
  if(daytime) {
    for(i in daytime) {
      if(daytime[i] > day_minutes) {
        return i;
      }
    }
  } else {
    return day_minutes;
  }
};

// Time Selector Module
var $selector = $('#selector');

// TODO: minutes from now.
var min_time = 840; // Now
var set_time = 1200; // 8PM
var max_time = 1640; // Tomorrow Night

var temp_time = 20;
var startX = undefined;
var currentX = 0;
var range = $selector.width();

var formatTime = function(time){
  if(time > 1440) {
    return "Tomorrow";
  } else {
    if(time < min_time+60) {
      return "Now";
    }
    hours = Math.floor(time/60);
    minutes = time-(hours*60);
    if(time > set_time+60 || time < set_time-60) {
      minutes = Math.floor(minutes/15)*15;
    }
    if(minutes < 10) {
      minutes = "0"+minutes;
    }
    return hours+':'+minutes;
  }
};

$selector
.on('mousedown touchstart',function(e){
  startX = e.pageX;
  temp_time = set_time;
})
.on('mousemove touchmove',function(e){
  if(startX != undefined) {
    e.preventDefault();
    currentX = (e.pageX-startX)/(range-startX);
    if(currentX > 0) {
      temp_time = Math.round((max_time-set_time)*currentX+set_time);
    } else {
      factorX = 1-(e.pageX-startX)*-1/startX;
      temp_time = Math.round((set_time-min_time)*factorX+min_time);
    }
    $selector.text(formatTime(temp_time));
  }
})
.on('mouseup touchend',function(e){
  startX = undefined;
  set_time = temp_time;
})
.text(formatTime(1200));