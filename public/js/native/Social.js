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
	
	// deprecated
	// Retrieves a complete list of Facebook Contacts of the current user
	this.getFBContacts = function()
	{
		this.connector.removeNativeListener("getFBContacts", self._onFBContactsReceived);
		this.connector.callNativeMethod("getFBContacts");
		this.connector.addNativeListener("getFBContacts", self._onFBContactsReceived);
	}
	
	
	// deprecated
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
	
	this.getUser = function()
	{
		//this.connector.removeNativeListener("getUserData", self._onUserData);
		this.connector.callNativeMethod("getUserData");
		//this.connector.addNativeListener("getUserData", self._onUserData);
	}
	
	self._onUserData = function(data)
	{
		self._listeners["getUserData"](data);
	}
	
	this.saveCurrentState = function(state)
	{
		this.connector.callNativeMethod("saveCurrentState", state);
	}
	
	this.setInvitationState = function(state, id)
	{
		var inviteJSON = {"state":state, "id":id};
		this.connector.callNativeMethod("setInvitationState", JSON.stringify(inviteJSON));
	}
	
	this.getInvitedUser = function()
	{
		this.connector.removeNativeListener("getInvitedUser", self._onFBConnectionStateReceived);
		this.connector.callNativeMethod("getInvitedUser");
		this.connector.addNativeListener("getInvitedUser", self._onInvitedUserReceived);
	}
	
	this.getWWFriendsList = function()
	{
		this.connector.removeNativeListener("getWWFriendsList", self._onWWFriendsListReceived);
		this.connector.callNativeMethod("getWWFriendsList");
		this.connector.addNativeListener("getWWFriendsList", self._onWWFriendsListReceived);
	}
	
	self._onInvitedUserReceived = function(data)
	{
		self._listeners["getInvitedUser"](data);
	}
	
	self._onWWFriendsListReceived = function(data)
	{
		self._listeners["getWWFriendsList"](data);
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