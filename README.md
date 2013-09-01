#About
DDEnhancedJSBridge is an easy-to-use Javascript-ObjC bridge for IOS and OSX partly **based on the ideas of the JSBridge project**.

It is platform neutral and uses the same ObjC Code and also the same JS Code for **IOS and OSX**. 

DDEnhancedJSBridge comes as a workspace that includes a project for building the bridge as a **static library** and also **includes demo projects** for the two platforms that in large parts share the same source code. 

Bridging works by converting the parameters to-and-from JSON. Supported are therefory all datatypes that can be expressed as JSON. (On the javascript side, there is a special case for <img> elements. They are transparently converted to base64 data)

##Usage

###bridge from Javascript to Objective-C
To enable the bridge, you:

1. You got to replace the (UI)WebView class for the `DDBridgableWebView`. (The class is a drop in replacement that keeps all delegate methods intact and has the same behaviour as before.)<br/><br/>
Under IOS this class catches redirects using the ddbridge url scheme. Under OSX, it inserts itself as custom object into the Javascript Context of the html page.<br/>
    **The `DDBridgableWebView` is responsible for intercepting the Javascript and notifies the `DDEnhancedJSBridge` class of any requests**
  

2. You have to register all your bridgable WebViews and receiving Objects so the bridge knows what to bridge where. E.G. for IOS you'd do it in `viewDidLoad`. In OSX maybe in `awakeFromNib`?

            - (void)viewDidLoad
            {
                [super viewDidLoad];
	
                //register everybody
                [[DDEnhancedJSBridge defaultBridge] addWebView:self.webView];
                [[DDEnhancedJSBridge defaultBridge] addObject:self.imagefilter forName:@"imagefilter"];
            }

3. Add the DDBridge.js javascript files to your app's build phase <br/>
!Make sure it isn't added to the sources instead -- xcode 4 and 5 all want to compile JS, not copy i t
![Copy Build Phase](https://raw.github.com/Daij-Djan/DDEnhancedJSBridge/master/README-files/copy_files.png)

4. Write your javascript to use the bridge. To send a Command you create a new instance of the DDBridge object in javascript. E.G.

            function processImage(imgId)
            {
                var obj = new DDBridgeObj();
                obj.addObject("data", document.getElementById(imgId));
                obj.addObject("callback", "applyResultImage");
                
                obj.sendBridgeObject("imagefilter", "setMaskImage");
            }

5. Now the last step to actually have the object expose the called selector. In this case `setMaskImage`. To expose selectors all you have to do is follow a convention.  selectors therefore need to have the following signature:<br/>
` - (void)%name%:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView*)webview`<br/><br/>
so in our example:<br/>

        @interface DDImageFilter : NSObject<DDBridgableObject>
        
        //exposed to the web
        - (void)setImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview;
        - (void)setMaskImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview;
        
        @end

#####The image filter is now registered and reachable from Javascript.

##vice-versa: from Objective-C to javascript

this direction is rather trivial as you can already just call JS via the framework. but to provide a seamless API and some additional convenience I wrapped that in a method:

    ///sends JSON to the specified webview by calling a JSMethod
    - (void)bridgeFromNative:(id<DDBridgableObject>)o toWebview:(id<DDBridgableWebView>)wv userInfo:(NSDictionary*)userInfo;
    
When calling this on the bridge to make a JS Call the userInfo dictionary MUST contain a param named 'method' that specifies the javascript function to call.

 the js function must have the signature:<br/>
 `%name%(parametersJSONDictionary, senderName)`
 
 `senderName` specifies the name of the object as it was registered with the bridge.
 
#####A typical idiom is that the exposed object answers from within its exposed selector
To answer from to a call bridged FROM JS, call the above method like in this example: 

    - (void)setMaskImage:(NSDictionary*)params bridgedFrom:(id<DDBridgableWebView>)webview {
        _imageMask = [[DDImage alloc] initWithData:[NSData dataFromBase64String:params[@"data"]]];
        [self buildResultAndDeliverTo:webview as:params[@"callback"]];
    }

    - (void)buildResultAndDeliverTo:(id<DDBridgableWebView>)wv as:(NSString*)cb {
        ...    
        NSMutableDictionary *dict = @{@"data" : @"", @"method" : cb}.mutableCopy;
        ...     
    
        if([_bridge canBridgeFromNative:self toWebview:wv userInfo:dict]) {
            [_bridge bridgeFromNative:self toWebview:wv userInfo:dict];
        }
    }



###AVAIABLE under MIT