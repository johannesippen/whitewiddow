// Returns String from Geolocation
var ll = function(ll_array) {
  return ll_array[0]+','+ll_array[1];
};

// Returns Geo Midpoint between my_ll and friend_ll
var getMidpoint = function(my_ll, friend_ll) {
  midpoint = [((friend_ll[0]+my_ll[0])/2),((friend_ll[1]+my_ll[1])/2)];
  return midpoint;
};

// Generates Static Google Map with Geo Midpoint between my_ll and friend_ll, defines Width and Height
var staticMapUrl = function(my_ll, friend_ll, w, h) {
  var mapSrc = "http://maps.googleapis.com/maps/api/staticmap";
      mapSrc += "?markers="+ll(my_ll)+'|'+ll(friend_ll)+'&markers=color:blue%7C'+ll(getMidpoint(my_ll,friend_ll));
      mapSrc += "&size=" + w + "x" + h;
      mapSrc += "&sensor=false";
  return mapSrc;
};