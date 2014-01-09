var Maps = function()
{
	this.connector = new NativeConnector();	
	this.showMap = function()
	{
		this.connector.callNativeMethod("showMap");
	}
	
	this.hideMap = function()
	{
		this.connector.callNativeMethod("hideMap");
	}
	
	this.addMarker = function(lat, lon)
	{
		var position = {"latitude":lat, "longitude":lon};
		this.connector.callNativeMethod("addMarker", JSON.stringify(position));
	}
}