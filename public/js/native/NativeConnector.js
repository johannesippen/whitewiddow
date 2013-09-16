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
		_nativeListener[nativeType](JSON.parse(data).data);
	}
	
	this.callNativeMethod = function(method)
	{
		window.location.href = "native://"+method;
		writeLog("Call iOS-Method: "+method);
	}
}