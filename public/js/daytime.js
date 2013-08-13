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