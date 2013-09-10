/*
 * This script provides a mechanism for Wayback to communicate with the NLA's
 * Wayback/TNH based web archive application since this page will be rendered
 * in an iframe contained within this application and the parent application
 * needs to be told by the iframe which URL it is currently displaying so that
 * the application can display a suitable archival URL for the user to bookmark.
 */

 if (typeof console === 'undefined') {
    console = { 
        log: function(){}, 
        debug: function() {}, 
        info: function() {}, 
        warn: function() {}, 
        error: function() {}
    };
}

/*
 * Create a namespace to make it VERY unlikely that any of our Javascript code will collide
 * with any Javascript code from the archived page being replayed
 */
_NationalLibraryOfAustralia_WebArchive = {
    agwaUrlErrMsg: 'The base URL for AGWA has not been set so Wayback cannot communicate with AGWA',
    
    agwaReplayUrl: function(url) {
        if (!this.agwaUrl) {
            throw this.agwaUrlErrMsg;
        } else {
            /*
             * replayUriRef is a URI reference (i.e. partial identifier for archived resource)
             * See http://en.wikipedia.org/wiki/Uniform_resource_identifier#URI_reference
             */
            var replayUriRef = this.getReplayUriRef(url);
            console.info("replayUri: " + replayUriRef);
            if (replayUriRef === false) {
                throw 'Error: replayUriRef is false';
            } else {
                return this.agwaUrl + replayUriRef;
            }
        }
    },
    
    getReplayUriRef: function(url) {
        var n = this.waybackUrl.length;
        var link = document.createElement('a');
        var serverUrl;
        link.href='/';
        serverUrl = (link.href + '').slice(0, -1);
         
        if (url.substr(0, serverUrl.length) === serverUrl) {
            url = url.substr(serverUrl.length);
        }
        
        if (this.waybackUrl != url.substr(0, n)) {
            console.error("Supposed Wayback replay URL does not have waybackUrl as prefix");
            console.error("URL is " + url);
            console.error("waybackUrl is " + this.waybackUrl);
            return false;
        } else {
            // replayUri should be in the form /<timestamp>/<archived-url>
            var replayUri = url.substr(n);
            return replayUri;
        }
    },
    
    makeAgwaPrefixQueryUrl: function(prefixUrl) { 
        if (!this.agwaUrl) {
            alert(this.agwaUrlErrMsg);
            throw this.agwaUrlErrMsg;
        } else {
            // return this.agwabaseUrl + '/search?mode=urlSearch&urlQueryType=prefix&source=url&url=' + parentUrl
            return this.agwaPrefixQueryUrl.replace('{{URL}}', prefixUrl);
        }
    },

    setAgwaUrl: function(agwaUrl) {
        this.agwaUrl = agwaUrl;
        
        var doubleSlashPos = agwaUrl.indexOf('://');
        var endOfHostPos = agwaUrl.indexOf('/', doubleSlashPos + 3);
        if (endOfHostPos != -1) {
            this.agwaOriginUrl = agwaUrl.slice(0, endOfHostPos);
        } else {
            this.agwaOriginUrl = agwaUrl;
        }
    },
    
    setWaybackUrl: function(waybackUrl) {
        this.waybackUrl = waybackUrl;
    },
    
    setPrefixQueryUrl: function(url) {
        this.agwaPrefixQueryUrl = url;
    },
    
    /*!
     * contentloaded.js
     *
     * Author: Diego Perini (diego.perini at gmail.com)
     * Summary: cross-browser wrapper for DOMContentLoaded
     * Updated: 20101020
     * License: MIT
     * Version: 1.2
     *
     * URL:
     * http://javascript.nwbox.com/ContentLoaded/
     * http://javascript.nwbox.com/ContentLoaded/MIT-LICENSE
     *
     */
    // @win window reference
    // @fn function reference
    contentLoaded: function(win, fn) {
        var done = false, top = true,

	    doc = win.document, root = doc.documentElement,

	    add = doc.addEventListener ? 'addEventListener' : 'attachEvent',
	    rem = doc.addEventListener ? 'removeEventListener' : 'detachEvent',
	    pre = doc.addEventListener ? '' : 'on',

	    init = function(e) {
		    if (e.type == 'readystatechange' && doc.readyState != 'complete') return;
		    (e.type == 'load' ? win : doc)[rem](pre + e.type, init, false);
		    if (!done && (done = true)) fn.call(win, e.type || e);
	    },

	    poll = function() {
		    try { root.doScroll('left'); } catch(e) { setTimeout(poll, 50); return; }
		    init('poll');
	    };

	    if (doc.readyState == 'complete') fn.call(win, 'lazy');
	    else {
		    if (doc.createEventObject && root.doScroll) {
			    try { top = !win.frameElement; } catch(e) { }
			    if (top) poll();
		    }
		    doc[add](pre + 'DOMContentLoaded', init, false);
		    doc[add](pre + 'readystatechange', init, false);
		    win[add](pre + 'load', init, false);
	    }
    },
    
    // from http://javascriptrules.com/2009/07/22/cross-browser-event-listener-with-design-patterns/
    addEvent: function(el, ev, fn) {
        var addEvent;
        if (el.addEventListener) {
            addEvent = function (el, ev, fn) {
                el.addEventListener(ev, fn, false);
            };
        } else if (el.attachEvent) {
            addEvent = function (el, ev, fn) {
                el.attachEvent('on' + ev, fn);
            };
        } else {
            addEvent = function (el, ev, fn) {
                el['on' + ev] =  fn;
            };
        }
        addEvent(el, ev, fn);
    },


    /* 
     * Post a message to the parent window. This will be detected, validated and
     * handled by the NLA Web Archive application.
     */
    postMessage: function(message) {
        top.postMessage(message, this.agwaOriginUrl);
    },
    
    resourceNotFound: function() {
        this.postMessage({type: 'state', data: 'resourceNotFound'})
    },
    
    windowIsIframe: function() {
        var t = window.top;
        var s = window.self;
        console.debug('Wayback: Window is ' + ((t !== s) ? '' : 'not ') + ' iframe');
        return (t !== s);
    },
    
    windowParentIsBrowserWindow: function() {
        var t = window.top;
        var p = window.parent;        
        console.debug('Wayback: Window parent is ' + ((p === t) ? '' : 'not ') + 'browser window');
        return (p === t);
    },
    
    windowIsBrowserWindow: function() {
        var t = window.top;
        var s = window.self;
        console.debug('Wayback: Window is ' + ((s === t) ? '' : 'not ') + 'browser window');
        return (s === t);
    },
    
    displayInNLAWebArchiveGUI: function() {
        var app = _NationalLibraryOfAustralia_WebArchive;
        
        var redirectUrl = app.agwaReplayUrl(window.location.href);
        /**
         * Useful for debugging - uncomment the if statement below
         * to interrupt the automatic Javascript-driven redirect to an AGWA
         * replay URL
         */
        //if (confirm(app.agwaUrl)) {
            window.location.replace(redirectUrl);
        //} 
        
        console.debug("Wayback: redirecting to AGWA replay URL: " + redirectUrl);
        window.location.replace(redirectUrl);
    },
    
    setUp: function() {
        var app = this;
        
        app.contentLoaded(window, function() {
            console.log("Wayback: Replay content loaded, url: " + window.location.href);
            
            console.debug("Wayback: Window is " + app.windowIsIframe() ? '' : 'not ' + 'an iframe');
            /* If the document is being displayed in the browser
             * window instead of the #replayFrame iframe element as it should
             * be, redirect the browser to a URL which will redisplay the 
             * document in the correct context (in the #replayFrame iframe
             * wrapped with the rest of the NLA Web Archive GUI).
             */             
            if (app.windowIsBrowserWindow()) {
                app.displayInNLAWebArchiveGUI();
                return;
            }
            
            var title = document.title ? document.title : '';
            
            // If the document is being rendered in the #replayFrame iframe
            // created by the NLA Web Archive application then inform the
            // NLA Web Archive application that a new URL is being rendered.
            if (app.windowParentIsBrowserWindow()) {
                console.info("Wayback: Posting message 'replay-url-changed' to AGWA window, new URL=" + window.location.href); 
                /**
                 * Useful for debugging - uncomment the if statement below
                 * to intercept the 'replay-url-changed' message being posted to
                 * the parent window (AGWA).
                 */
                //if (confirm("Do you want to post a 'replay-url-changed' message to AGWA?")) {
                    app.postMessage({type: 'replay-url-changed', data: {url: document.location.href, title: title}});
                //}
            }
        });    
    }
}

_NationalLibraryOfAustralia_WebArchive.setUp();



