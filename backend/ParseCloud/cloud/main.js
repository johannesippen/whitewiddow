// Main.js from Jo, just testing deploy
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("getVenues", function(request, response) 
{
    // Input: friendId(s)
    var friendIds = request.params.friendIds;
    var user = request.user;
    console.log("User: "+JSON.stringify(user)); 
    // get friend location(s)
    var friendQuery = new Parse.Query("User");
       
    friendQuery.equalTo("objectId", friendIds);
    friendQuery.find(function(friendQueryResult)
    {
        //console.log("friendQueryResult: "+JSON.parse(friendQueryResult));
        var friendLocation;
        var userLocation;
        var venueResult = new Array();
        if(friendQueryResult.length > 0)
        {
            friendLocation = friendQueryResult[0]["attributes"]["lastLocation"];
               
            // get user location
            var userQuery = new Parse.Query("User");
            userQuery.equalTo("objectId", user.id);
            userQuery.find(function(userQueryResult)
            {
                userLocation = userQueryResult[0]["attributes"]["lastLocation"];
                // calculate middle
                var middle = calculateMiddle(friendLocation, userLocation);
                // calculate middle of middle and friend(s)
                var friendMiddle = calculateMiddle(middle, friendLocation);
                // calculate middle of middle and user
                var userMiddle = calculateMiddle(middle, userLocation);
                   
                   
                // 1) try to get venues out of the database
                   
                // This is not perfect, but it works: If Distance between peers is too big, it will increase the Foursquare Radius  
                console.log('Distance:'+getDistanceFromLatLonInKm(userLocation.latitude,userLocation.longitude,middle.latitude,middle.longitude)*500); //TODO: Remove, Test
                /*
                radius = 500;
                if(getDistanceFromLatLonInKm(userLocation.latitude,userLocation.longitude,middle.latitude,middle.longitude) > 1000) {
                  radius = 20000;
                }
                */
                 
                // Radius:
                if(getDistanceFromLatLonInKm(userLocation.latitude,userLocation.longitude,middle.latitude,middle.longitude) > 1) {
                  radius = Math.round(getDistanceFromLatLonInKm(userLocation.latitude,userLocation.longitude,middle.latitude,middle.longitude)*500);                  
                } else {
                  radius = 500;
                }
 
                   
                // 4) if venueCount (moderated and favorite does not count) is less than 5 then try to get foursquare venues
                var middlePromise = loadFoursquareData(middle, radius, "middle", venueResult, userLocation);
                var friendPromise = loadFoursquareData(friendMiddle, radius, "friend", venueResult, userLocation);
                var userPromise = loadFoursquareData(userMiddle, radius, "mine", venueResult, userLocation);
                   
                Parse.Promise.when(middlePromise, friendPromise, userPromise).then(
                function(r1, r2, r3)
                {
                       
                    response.success(venueResult);
                });
                   
            });
               
        }
        else
        {
            response.error("No Friend found for id: "+friendIds);
        }
   
           
    });
       
       
    function loadFoursquareData(location, radius, type, venueList, userLoc)
    {
       
        return Parse.Cloud.httpRequest({
                    url: 'https://api.foursquare.com/v2/venues/search',
                    params: 
                    {
                        ll: location.latitude+","+location.longitude,
                        radius: radius,
                        categoryId:  "4bf58dd8d48988d116941735",
                        intent: "browse",
                        oauth_token: "B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV",
                        v:"20130811"
                    },
                    success: function(httpResponse) 
                    {
                        var response = JSON.parse(httpResponse.text);
                        var venues = response.response.venues;
                        if(venues.length == 0)
                        {
                            // TODO: Best Case: If this has been executed a 3rd time either wait or return standard venue.
                            radius = radius*2;
                            loadFoursquareData(location, radius, type, venueList, userLoc);
                        }
                           
                        highestCheckin = 0;
                        var bestVenue;
                        var venueAlreadyChosen = false;
                        for(i = 0; i < venues.length; ++i)
                        {
                            venueAlreadyChosen = false;
                            if(highestCheckin < venues[i]["stats"]["checkinsCount"])
                            {
                                // Check if venue is already chosen
                                   
                                for(j = 0; j < venueList.length; ++j)
                                {
                                    if(venues[i]["id"] == venueList[j]["venue"]["id"])
                                    {
                                        venueAlreadyChosen = true;
                                        break;
                                    }
                                }
                                if(!venueAlreadyChosen)
                                {
                                    bestVenue = venues[i];
                                    highestCheckin = venues[i]["stats"]["checkinsCount"];
                                }
                            }
                        }
                           
                        if(!bestVenue)
                        {
                            radius = radius*2;
                            return loadFoursquareData(location, radius, type, venueList, userLoc);
                        }
                        else
                        {
                            var distance = getDistanceFromLatLonInKm(bestVenue["location"]["lat"], bestVenue["location"]["lng"], userLoc.latitude, userLoc.longitude);
                            bestVenue["distanceToMe"] = distance*1000;
                               
                            // Save to Database
                            var lookupQuery = new Parse.Query("Venues");
                            console.log("venueID: "+bestVenue["id"]);
                            lookupQuery.equalTo("venueID", bestVenue["id"]);
                            lookupQuery.find(function(lookupResult)
                            {
                                console.log(JSON.stringify(lookupResult));
                                if(lookupResult.length == 0)
                                {
                                    var LookupVenue = Parse.Object.extend("Venues");
                                    var lookupVenue = new LookupVenue();
                                        
                                    lookupVenue.set("venueID", bestVenue["id"]);
                                    lookupVenue.set("venueName", bestVenue["name"]);
                                    var point = new Parse.GeoPoint({latitude: bestVenue["location"]["lat"], longitude: bestVenue["location"]["lng"]});
                                    lookupVenue.set("venueLocation", point);
                                    lookupVenue.set("venueType", 1);
                                    lookupVenue.save();
                                }
                            });
                               
                            venueList.push({"type" : type, "venue" : bestVenue});
                        }
                    },
                    error: function(httpResponse) 
                    {
                        console.error('Request failed with response code ' + httpResponse.status);
                    }
                });
    }
       
    function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) 
    {
      var R = 6371; // Radius of the earth in km
      var dLat = deg2rad(lat2-lat1);  // deg2rad below
      var dLon = deg2rad(lon2-lon1); 
      var a = 
        Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
        Math.sin(dLon/2) * Math.sin(dLon/2)
        ; 
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
      var d = R * c; // Distance in km
      return d;
    }
       
    function deg2rad(deg) {
      return deg * (Math.PI/180)
    }
       
    function calculateMiddle(locA, locB)
    {
        var middle = {};
           
        var lon1 = locA.longitude * Math.PI / 180;
        var lon2 = locB.longitude * Math.PI / 180;
       
        var lat1 = locA.latitude * Math.PI / 180;
        var lat2 = locB.latitude * Math.PI / 180;
       
        var dLon = lon2 - lon1;
       
        var x = Math.cos(lat2) * Math.cos(dLon);
        var y = Math.cos(lat2) * Math.sin(dLon);
       
        var lat3 = Math.atan2( Math.sin(lat1) + Math.sin(lat2), Math.sqrt((Math.cos(lat1) + x) * (Math.cos(lat1) + x) + y * y) );
        var lon3 = lon1 + Math.atan2(y, Math.cos(lat1) + x);
       
        middle.latitude  = lat3 * 180 / Math.PI;
        middle.longitude = lon3 * 180 / Math.PI;
           
        return middle;
    }
       
       
       
       
       
    // 2) try to get favorite venues (tbd)
       
    // 3) try to get moderated venues
       
    // 5) if foursquare is not reachable try to get venues from yelp
});
   
Parse.Cloud.define("searchVenue", function(request, response) 
{
    var user = request.user;
    var radius = 20000;
    var latitude = request.params.latitude;
    var longitude = request.params.longitude;
    var searchTerm = request.params.searchTerm;
    Parse.Cloud.httpRequest({
                    url: 'https://api.foursquare.com/v2/venues/search',
                    params: 
                    {
                        ll: latitude+","+longitude,
                        //radius: radius,
//                        categoryId:  "4bf58dd8d48988d116941735",
                        oauth_token: "B2YI5GXCW022WC3F4FLP5SFHGGLG1LA0DCT2QSGQTXQVBYWV",
                        v:"20130811", 
                        query:searchTerm
                    },
                    success: function(httpResponse) 
                    {
                        console.log("searchResponse:"+httpResponse.text);
                        var responses = JSON.parse(httpResponse.text);
                        var venues = responses.response.venues;
                           
                        if(venues.length == 0)
                        {
                            response.success({"type" : "nothing"});
                            return;
                        }
                           
                           
                        var bestVenue = venues[0];
                           
                           
                        var distance = getDistanceFromLatLonInKm(bestVenue["location"]["lat"], bestVenue["location"]["lng"], latitude, longitude);
                        bestVenue["distanceToMe"] = distance*1000;
                               
                        // Save to Database
                        var lookupQuery = new Parse.Query("Venues");
                        console.log("venueID: "+bestVenue["id"]);
                        lookupQuery.equalTo("venueID", bestVenue["id"]);
                        lookupQuery.find(function(lookupResult)
                        {
                            console.log(JSON.stringify(lookupResult));
                            if(lookupResult.length == 0)
                            {
                                var LookupVenue = Parse.Object.extend("Venues");
                                var lookupVenue = new LookupVenue();
                                    
                                lookupVenue.set("venueID", bestVenue["id"]);
                                lookupVenue.set("venueName", bestVenue["name"]);
                                var point = new Parse.GeoPoint({latitude: bestVenue["location"]["lat"], longitude: bestVenue["location"]["lng"]});
                                lookupVenue.set("venueLocation", point);
                                lookupVenue.set("venueType", 1);
                                lookupVenue.save();
                            }
                        });
                        response.success({"type" : "search", "venue" : bestVenue});
                    },
                    error: function(httpResponse) 
                    {
                        console.error('Request failed with response code ' + httpResponse.status);
                    }
                });
    function getDistanceFromLatLonInKm(lat1,lon1,lat2,lon2) 
    {
      var R = 6371; // Radius of the earth in km
      var dLat = deg2rad(lat2-lat1);  // deg2rad below
      var dLon = deg2rad(lon2-lon1); 
      var a = 
        Math.sin(dLat/2) * Math.sin(dLat/2) +
        Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * 
        Math.sin(dLon/2) * Math.sin(dLon/2)
        ; 
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
      var d = R * c; // Distance in km
      return d;
    }
       
    function deg2rad(deg) {
      return deg * (Math.PI/180)
    }
});
   
   
   
// return values for different states
// 0: no Event found
// 1: pending Event found
// 2: Event request found
// 3: Upcoming Event found
// 4: Running Event found?
Parse.Cloud.define("getEventState", function(request, response)
{
    console.log("getEventState");
    // Get pending Events
    var user = request.user;
    var resultObject = {};
    // Dates between today 2 o'clock and tomorrow 2 o'clock
    var now = new Date();
    var timeEdgecase = false;
       
    // Edgecase Time is between 0 and 2 o'clock
    if(now.getHours() >= 0 && now.getHours() < 2)
    {
        timeEdgecase = true;
    }
       
    now.setHours(2);
    now.setMinutes(0);
    now.setSeconds(0);
    now.setMilliseconds(0);
    var borderToday = now;
    var borderTomorrow = new Date();
       
    // Edgecase Time will be set to 2 o'clock yesterday and 2 o'clock today
    if(timeEdgecase)
    {
        borderTomorrow.setTime(now);
        borderToday.setTime(now.getTime()-(24*60*60*1000));
    }
    else
    {
        borderTomorrow.setTime(now.getTime()+(24*60*60*1000));
    }
       
       
    var userQuery = new Parse.Query("EventAttendees");
    userQuery.equalTo("Attendee", user);
    userQuery.greaterThan("createdAt", borderToday);
    userQuery.lessThan("createdAt", borderTomorrow);
    userQuery.descending("createdAt");
       
    var isResponse = false;
    var eventAttendee;
    var attendeeState;
    var isOrganisator;
    userQuery.find(function(userResult)
    {
        // No matching users found, means: there are no given events
        if(userResult.length == 0)
        {
            console.log("No Event found!");
            resultObject["statusCode"] = 0;
            response.success(resultObject);
            return;
        }
           
           
        for(var i = 0; i < userResult.length; ++i)
        {
            console.log("userResult["+i+"]" + JSON.stringify(userResult[i]));
            eventAttendee = userResult[i];          
            attendeeState = eventAttendee["attributes"].invitationState;
            isOrganisator = eventAttendee["attributes"].organisator;
               
            console.log("attendeeState: "+attendeeState+", isOrganisator: "+isOrganisator);
               
            switch(attendeeState)
            {
                case 1:
                    resultObject["statusCode"] = 2;
                    isResponse = true;
                break;
                   
                case 2:
                    isResponse = true;
                break;
                   
                case 3:
                    resultObject["statusCode"] = 0;
                    isResponse = true;
                break;
            }
            if(isResponse)
            {
                break;
            }
        }
           
        if(!isResponse)
        {
            console.log("No Event found!");
            resultObject["statusCode"] = 0;
            response.success(resultObject);
            return;
        }
           
        // Query for eventdata
           
        console.log("event: "+JSON.stringify(eventAttendee));
           
        var eventQuery = new Parse.Query("Event");
        eventQuery.containsAll("attendees", [eventAttendee]);
        eventQuery.include("attendees");
        eventQuery.include("attendees.Attendee");
        eventQuery.find(function(result)
        {
            console.log("event: "+JSON.stringify(result));
            resultObject["event"] = result[0];
               
            if(isOrganisator && attendeeState == 2)
            {
                var everyoneAccepted = true;
                var eventAttendees = result[0]["attributes"]["attendees"];
                for(var j = 0; j < eventAttendees.length; ++j)
                {
                    if(eventAttendees[j]["attributes"].invitationState == 1)
                    {
                        everyoneAccepted = false;
                    }
                }
                resultObject["statusCode"] = (everyoneAccepted) ? 3 : 1;
            }
            else if(attendeeState == 2)
            {
                resultObject["statusCode"] = 3;
            }
               
            response.success(resultObject);
        });
    });
});
