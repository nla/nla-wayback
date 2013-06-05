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
    agwaBaseUrlErrMsg: 'AGWA base URL has not been set so Wayback cannot communicate with AGWA',
    
    makeAgwaReplayUrl: function(waybackReplayUrl) {
        var encodedUrl = encodeURIComponent(waybackReplayUrl);
        return this.agwaReplayUrl(encodedUrl);
    },
    
    agwaReplayUrl: function(url) {
        if (!this.agwaBaseUrl) {
            alert(this.agwaBaseUrlErrMsg);
            throw this.agwaBaseUrlErrMsg;
        } else {
            return this.agwaBaseUrl + '/replay/wrapWaybackUrl?wbUrl=' + url;
        }
    },
    
    makeAgwaPrefixQueryUrl: function(prefixUrl) { 
        if (!this.agwaBaseUrl) {
            alert(this.agwaBaseUrlErrMsg);
            throw this.agwaBaseUrlErrMsg;
        } else {
            // return this.agwabaseUrl + '/search?mode=urlSearch&urlQueryType=prefix&source=url&url=' + parentUrl
            return this.agwaPrefixQueryUrl.replace('{{URL}}', prefixUrl);
        }
    },

    setBaseUrl: function(url) {
        this.agwaBaseUrl = url;
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
        top.postMessage(message, this.agwaBaseUrl);
    },
    
    resourceNotFound: function() {
        this.postMessage({type: 'state', data: 'resourceNotFound'})
    },
    
    windowIsIframe: function() {
        return (window.top != window.self);
    },
    
    windowParentIsBrowserWindow: function() {
        return (window.parent == window.top);
    },
    
    windowIsBrowserWindow: function() {
        return (window.self == window.top);
    },
    
    displayInNLAWebArchiveGUI: function() {
        var app = _NationalLibraryOfAustralia_WebArchive;
        window.location.replace(app.makeAgwaReplayUrl(window.location.href));
        app.postMessage({type: 'replay-url-opened-new-window', data: {url: document.location.href, title: title}});
    },
    
    setUp: function() {
        var app = this;
        
        app.contentLoaded(window, function() {
            console.log("Wayback replay - url = " + document.location.href);
            
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
                app.postMessage({type: 'replay-url-changed', data: {url: document.location.href, title: title}});
            }
        });    
    }
}

_NationalLibraryOfAustralia_WebArchive.setUp();



