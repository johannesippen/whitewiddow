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
var getVenue = function(location_ll, is_midpoint, is_my_hood, is_friend_hood) {
  var category = '4bf58dd8d48988d116941735'; // Foursquare Nightlife
  var radius = 500;
  var token = 'B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV';
  
  var url = 'https://api.foursquare.com/v2/venues/search'
      url += '?ll='+ll(location_ll);
      url += '&radius='+radius;
      url += '&categoryId='+category;
      url += '&intent=browse&oauth_token='+token+'&v=20130811';
  
  $.getJSON(url,function(data){
	  venues = data.response.venues;
	  if(venues.length > 0) {
	    
	    // TODO: This is a good point to insert some location chooser magic. Right now we just take the first result.
      venue_ll = [venues[0].location.lat,venues[0].location.lng];
      
      if(is_midpoint) {
        // TODO: This updates the Map & the #venue field. Make this better.
        map.src = staticMapUrl(my_coordinates,friend_coordinates,320,320,venue_ll);
  	    $('#venue').text(venues[0].name);
  	    $('#midpoint_venue').append(venues[0].name);
      }
      
      // TODO: This shows the closest places around you and your friend. Remove this later
      if(is_my_hood) {
        $('#my_hood').append(venues[0].name);
      }
      
      if(is_friend_hood) {
        $('#friend_hood').append(venues[0].name);
      }
	  }
	});
}