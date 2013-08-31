/*
2013 sapient gmbh

 This javascript code is part of the DDBridge api. It is used to communicate
 data to Objective-C code through a UIWebView/webview.
 */

// Counts the number of objects communicated to the Objective-C code. 
// It is used to index data in the DDBridge_objArray.
var DDBridge_objCount = 0;

// Keeps the objects that should be communicated to the Objective-C code.
var DDBridge_objArray = new Array();

/*
	Builds an empty instance of a DDBridge object.
 */
function DDBridgeObj()
{
	this.objectJson = "";
	this.addObject = DDBridgeObj_AddObject;
	this.sendBridgeObject = DDBridgeObj_SendObject;
}

/*
	The addObject method implementation for the DDBridge object.
    obj must be compatible with JSON or... an img element in which case ill take its data
 */
function DDBridgeObj_AddObject(id, obj)
{
    if(typeof(obj) == "object" && obj.nodeName == "IMG")
    {
        obj = helper_getBase64Image(obj);
    }

    var result = JSON.stringify(obj);
    
	if(result != "")
	{
		if(this.objectJson != "")
		{
			this.objectJson += ", ";
		}
		this.objectJson += '"' + id + '":' + result;
	}
}


/*
	This method sends the object to the Objective-C code. Basically, 
	it tries to load a special URL, which passes the object id.
 */
function DDBridgeObj_SendObject(component, method)
{
	DDBridge_objArray[DDBridge_objCount] = this.objectJson;
	
    var url = "";
    if(method)
        url = "DDBridge://"+component+"/"+method+"?"+"ReadNotificationWithId=" + DDBridge_objCount;
	else
        url = "DDBridge://"+component+"/" + DDBridge_objCount;
        
	if ( window.DDBridgableWebView ) {
		/* calls our Objective-C console logging function */
		window.DDBridgableWebView.bridgeUrl(url);
	}
    else {
        window.location.href = url;
    }
    
	DDBridge_objCount++;
}

/*
	This method is invoked by the Objective-C code. It retrieves the json string representation
	of a DDBridge object given its id.
 */
function DDBridge_getJsonStringForObjectWithId(objId)
{
	var jsonStr = DDBridge_objArray[objId];
	
	DDBridge_objArray[objId] = null;
	
	return "{" + jsonStr + "}";
}

/*
 Receives as input an image object and returns its data
 encoded in a base64 string.
 
 This piece of code was based on Matthew Crumley's post
 at http://stackoverflow.com/questions/934012/get-image-data-in-javascript.
 */
function helper_getBase64Image(img) {
    // Create an empty canvas element
    var canvas = document.createElement("canvas");
	
	var newImg = new Image();
	newImg.src = img.src;
    canvas.width = newImg.width;
    canvas.height = newImg.height;
	
    // Copy the image contents to the canvas
    var ctx = canvas.getContext("2d");
    ctx.drawImage(newImg, 0, 0);
	
    // Get the data-URL formatted image
    var dataURL = canvas.toDataURL("image/png");
	
    return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
}