var NativeConnector = function()
{
	this.getFBContacts = "getFBContacts";
	this.getContacts = "getContacts";
	
	var _nativeListener = new Array();
	
	// Fügt einen Listener für Native Events hinzu
	this.addNativeListener = function(type, listener)
	{
		_nativeListener[type] = listener;
	}
	
	//TODO
	// Entfernt einen Listener für Native Events
	this.removeNativeListener = function(type, listener)
	{
		
	}
	
	// Wird aus Obj-C heraus aufgerufen
	_callJS = function(data)
	{
		var nativeType = JSON.parse(data).messageType;
		if(nativeType == "getWWFriendsList")
		{
			social._onWWFriendsListReceived(JSON.parse(data).data);
		}
		else if(nativeType == "getUserData")
		{
			social._onUserData(JSON.parse(data).data);
		}else if(nativeType == "getInvitedUser")
		{
			social._onInvitedUserReceived(JSON.parse(data).data);
		}	
		_nativeListener[nativeType](JSON.parse(data).data);
	}
	
	this.callNativeMethod = function(method, params)
	{
		//alert(method+": "+params);
		if(params)
		{
			window.location.href = "native://"+method+"&"+params;
		}
		else
		{
			window.location.href = "native://"+method;
		}
		writeLog("Call iOS-Method: "+method);
	}
}