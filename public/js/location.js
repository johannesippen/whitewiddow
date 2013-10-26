// Returns String from Geolocation
var ll = function(ll_array) {
  return ll_array[0]+','+ll_array[1];
};

$(function(){
  $.Event('ww:gotVenue', { bubbles: false });
});

$(document).on('ww:gotVenue', function(e, map, name){
  console.log(map,name)
})

// Returns Geo Midpoint between my_ll and friend_ll
var getMidpoint = function(my_ll, friend_ll) {
  midpoint = [((friend_ll[0]+my_ll[0])/2),((friend_ll[1]+my_ll[1])/2)];
  return midpoint;
};

// Generates Static Google Map with Geo Midpoint between my_ll and friend_ll, defines Width and Height
var staticMapUrl = function(my_ll, friend_ll, w, h, venue_ll) {
  var mapSrc = "http://maps.googleapis.com/maps/api/staticmap";
      mapSrc += "?markers="+ll(my_ll)+'|'+ll(friend_ll);
      if(venue_ll) {
        mapSrc += '&markers=color:green%7C'+ll(venue_ll);        
      } else {
        mapSrc += '&markers=color:blue%7C'+ll(getMidpoint(my_ll,friend_ll));
      }
      mapSrc += "&size=" + w + "x" + h;
      mapSrc += "&sensor=false";
  return mapSrc;
};

// Get the venue from Foursquare and puts it into the Map
var getVenue = function(location_ll, is_midpoint, is_my_hood, is_friend_hood, radius) {
  if(activate_daytime) {
    var category = activity[getDaytime()]; // Foursquare Nightlife
  } else {
    var category = '4bf58dd8d48988d116941735'; // Foursquare Nightlife
  }
  if(!radius) {
    var radius = 500;  
  }
  var token = 'B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV';
  
  var url = 'https://api.foursquare.com/v2/venues/search'
      url += '?ll='+ll(location_ll);
      url += '&radius='+radius;
      url += '&categoryId='+category;
      url += '&intent=browse&oauth_token='+token+'&v=20130811';
//      url = "https://api.foursquare.com/v2/venues/search?ll=52.529994200000004,13.408835700000001&radius=5000&categoryId=4bf58dd8d48988d1e0931735,4bf58dd8d48988d16d941735&intent=browse&oauth_token=B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV&v=20130811"
              //https://api.foursquare.com/v2/venues/search?ll=52.90875075801331,13.928215145934656&radius=500&categoryId=4bf58dd8d48988d116941735&intent=browse&oauth_token=B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV&v=20130811
  
      console.log(url);
  
  $.getJSON(url,function(data){
    venues = data.response.venues;
    if(venues.length > 0) {
      
      venue = selectVenue(venues);
      
      // TODO: This is a good point to insert some location chooser magic. Right now we just take the first result.
      venue_ll = [venue.location.lat,venue.location.lng];
      
      // TODO: This updates the Map
      map.src = staticMapUrl(my_coordinates,friend_coordinates,320,225,venue_ll);
      $('.map').attr('src',staticMapUrl(my_coordinates,friend_coordinates,320,225,venue_ll));
      
      if(is_midpoint) {
        // TODO: This updates the venue anme & distance field. Make this better.
        $('.invite_venue_name').text(venue.name);
        $('.invite_venue_distance').text(getDistance(my_coordinates,venue_ll)+'km, '+getTravelTime(my_coordinates,venue_ll)+'min');
      }
      
      // TODO: This shows the closest places around you and your friend. Remove this later
      if(is_my_hood) {
        $('.invite_venue_name').text(venue.name);
        $('.invite_venue_distance').text(getDistance(my_coordinates,venue_ll)+'km, '+getTravelTime(my_coordinates,venue_ll)+'min');
      }
      
      if(is_friend_hood) {
        $('.invite_venue_name').text(venue.name);
        $('.invite_venue_distance').text(getDistance(my_coordinates,venue_ll)+'km, '+getTravelTime(my_coordinates,venue_ll)+'min');
      }
    } else {
      $('.invite_venue_name').text('No Venue found');
      getVenue(location_ll, is_midpoint, is_my_hood, is_friend_hood, radius*2);
    }
  });
};

// From an Array of venues, choose the best one. Right now it's randomized
var selectVenue = function(venues) {
  i = Math.floor(Math.random()*venues.length);
  return venues[i];
};

// Calculate Distance between two users in kilometers
var getDistance = function(my_ll,friend_ll) {
   lat1 = my_ll[0];
   lon1 = my_ll[1];
   lat2 = friend_ll[0];
   lon2 = friend_ll[1];
   var R = 6371000000;
   var dLat = (lat2-lat1) * Math.PI / 180;
   var dLon = (lon2-lon1) * Math.PI / 180;
   var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
   Math.cos(lat1 * Math.PI / 180 ) * Math.cos(lat2 * Math.PI / 180 ) *
   Math.sin(dLon/2) * Math.sin(dLon/2);
   var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
   var d = R * c;
   return Math.round(d/100000)/10;
};

// Calculate Travel Time between two locations
var getTravelTime = function(my_ll,friend_ll) {
  var distance = getDistance(my_ll, friend_ll);
  if(distance > 1.5) {
    var time_per_km = 3; // TODO: 3min per kilometer. Works in Berlin. Make better!
  } else {
    var time_per_km = 10; // TODO: 10m per kilometer walking speed
  }
  var t = distance * time_per_km;
  return Math.round(t);
};