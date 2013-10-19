var Social = function()
{
	this.fbContacts = {};
	this.fbConnectedContacts = {};
	this.fbConnectionState;

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
	
	
	// Retrieves a complete list of Facebook Contacts of the current user
	this.getFBContacts = function()
	{
		this.connector.removeNativeListener("getFBContacts", self._onFBContactsReceived);
		this.connector.callNativeMethod("getFBContacts");
		this.connector.addNativeListener("getFBContacts", self._onFBContactsReceived);
	}
	
	// Retrieves a list of connected Facebook Contacts of the current user
	this.getConnectedFBContacts = function()
	{
		this.connector.removeNativeListener("getConnectedFBContacts", self._onFBConnectedContactsReceived);
		this.connector.callNativeMethod("getConnectedFBContacts");
		this.connector.addNativeListener("getConnectedFBContacts", self._onFBConnectedContactsReceived);
	}

	// Connects the device to a (given) facebook account and retrieves the connectionstate
	// {
	// 		connectionState: "UserCanceled" / "ErrorMessage" / "SignedUp" / "LoggedIn"
	// }
	this.connectFB = function()
	{
		this.connector.removeNativeListener("connectFB", self._onFBConnectionStateReceived);
		this.connector.callNativeMethod("connectFB");
		this.connector.addNativeListener("connectFB", self._onFBConnectionStateReceived);
	}
	
	this.inviteFBUser = function(id)
	{
		this.connector.removeNativeListener("inviteFBUser", self._onFBConnectionStateReceived);
		this.connector.callNativeMethod("inviteFBUser", id);
		this.connector.addNativeListener("inviteFBUser", self._onFBConnectionStateReceived);
	}
	
	this.getInvitedUser = function()
	{
		this.connector.removeNativeListener("getInvitedUser", self._onFBConnectionStateReceived);
		this.connector.callNativeMethod("getInvitedUser");
		this.connector.addNativeListener("getInvitedUser", self._onFBConnectionStateReceived);
	}
	
	self._onFBConnectionStateReceived = function(data)
	{
		self.fbConnectionState = data.connectionState;
		self._listeners["connectFB"](data);
	}
	
	self._onFBContactsReceived = function(data)
	{
		self.fbContacts = data;
		self._listeners["getFBContacts"](data);
	}
	
	self._onFBConnectedContactsReceived = function(data)
	{
		self.fbConnectedContacts = data;
		self._listeners["getConnectedFBContacts"](data);
	}
}