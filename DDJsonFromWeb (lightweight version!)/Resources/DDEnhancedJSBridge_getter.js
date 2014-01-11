/*
	This method is invoked by the Objective-C code. It retrieves the json string representation
	of a JS Element given its id.
 */
function getBridgedElementByID(objId)
{
    var elem = document.getElementById(objId);
	var jsonStr = helper_jsonifyObject(elem);
    return "{ \""+objId+"\": " + jsonStr + "}";
}

/*
 The addObject method implementation for the DDBridge object.
 obj must be compatible with JSON or... an img element in which case ill take its data
 */
function helper_jsonifyObject(obj)
{
    if(typeof(obj) == "object" && obj.nodeName == "IMG")
    {
        obj = helper_getBase64Image(obj);
    }
    
	return JSON.stringify(obj);
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