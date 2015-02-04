//
//  Action.js
//  AddUrl
//
//  Created by Kent Peifeng Ke on 2/4/15.
//  Copyright (c) 2015 Kent. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        // Here, you can run code that modifies the document and/or prepares
        // things to pass to your action's native code.
        
        // We will not modify anything, but will pass the body's background
        // style to the native code.
        
        var url = window.location.href;
        var title = document.title;
        
        alert(url+"\r\n"+title);
        
        arguments.completionFunction({ "currentBackgroundColor" : document.body.style.backgroundColor, "url":""+url, "title":""+title })
//        arguments.completionFunction({ "currentBackgroundColor" : document.body.style.backgroundColor })
    },
    
    finalize: function(arguments) {
        // This method is run after the native code completes.
        
        // We'll see if the native code has passed us a new background style,
        // and set it on the body.

        

        var newBackgroundColor = arguments["newBackgroundColor"]
        if (newBackgroundColor) {
            // We'll set document.body.style.background, to override any
            // existing background.
            document.body.style.background = newBackgroundColor
        } else {
            // If nothing's been returned to us, we'll set the background to
            // blue.
            document.body.style.background= "blue"
        }
        
        var redirectUrl = arguments["redirectUrl"];
        alert("redirecturl:"+redirectUrl);
        if(redirectUrl){
            document.body.innerText = redirectUrl;
            window.location.href = redirectUrl;
        }
        
    }
    
};
    
var ExtensionPreprocessingJS = new Action
