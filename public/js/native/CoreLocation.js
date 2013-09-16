var CoreLocation = function()
{
	this.connector = new NativeConnector();	
	this._listeners = {};
	var self = this;
	this.authorizationStatus;
	this.location;
	
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
	
	this.authorizeCoreLocation = function()
	{
		this.connector.removeNativeListener("getCoreLocationAuthorizeState", self._onCoreLocationAuthStatus);
		this.connector.callNativeMethod("authorizeCoreLocation");
		this.connector.addNativeListener("getCoreLocationAuthorizeState", self._onCoreLocationAuthStatus);
	}
	
	this.getAuthorizationState = function()
	{
		this.connector.removeNativeListener("getCoreLocationAuthorizeState", self._onCoreLocationAuthStatus);
		this.connector.callNativeMethod("getCoreLocationAuthorizeState");
		this.connector.addNativeListener("getCoreLocationAuthorizeState", self._onCoreLocationAuthStatus);
	}
	
	this.getLocation = function()
	{
		this.connector.removeNativeListener("getLocation", self._onLocationUpdate);
		this.connector.callNativeMethod("getLocation");
		this.connector.addNativeListener("getLocation", self._onLocationUpdate);
	}
	
	self._onCoreLocationAuthStatus = function(data)
	{
		self.authorizationStatus = data.authorizationStatus;
		self._listeners["getCoreLocationAuthorizeState"](data);
	}
	
	self._onLocationUpdate = function(data)
	{
		self.location = data;
		self._listeners["getLocation"](data);
	}
}