var Event = function()
{

	this.connector = new NativeConnector();	
	this._listeners = {};
	var self = this;
	
	// Fügt einen Listener für Native Events hinzu
	this.addNativeListener = function(type, listener)
	{
		this._listeners[type] = listener;
	}
	
	//TODO
	// Entfernt einen Listener für Native Events
	this.removeNativeListener = function(type, listener)
	{
		
	}
	
	this.createEvent = function(date, coord)
	{
		var eventJSON = {"date":Math.round(date.getTime()/1000), "latitude":coord[0], "longitude":coord[1]};
		this.connector.callNativeMethod("createEvent", JSON.stringify(eventJSON));
	}
	
	this.attendEvent = function(eventID)
	{
		this.connector.callNativeMethod("attendEvent", eventID);	
	}
	
	this.getEventById = function(eventID)
	{
		this.connector.callNativeMethod("getEventById", eventID);
	}
}