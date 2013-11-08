var PushNotification = function()
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
	
	this.authorizePushNotification = function()
	{
		this.connector.callNativeMethod("authorizePushNotification");
	}
}