<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"
%><%@ page import="java.util.Date"
%><%@ page import="java.util.Map"
%><%@ page import="java.util.Iterator"
%><%@ page import="java.lang.StringBuffer"
%><%@ page import="org.archive.wayback.archivalurl.ArchivalUrlDateRedirectReplayRenderer"
%><%@ page import="org.archive.wayback.ResultURIConverter"
%><%@ page import="org.archive.wayback.archivalurl.ArchivalUrl"
%><%@ page import="org.archive.wayback.core.UIResults"
%><%@ page import="org.archive.wayback.core.WaybackRequest"
%><%@ page import="org.archive.wayback.core.CaptureSearchResult"
%><%@ page import="org.archive.wayback.util.StringFormatter"
%><%@ page import="org.archive.wayback.util.url.UrlOperations"
%><%
UIResults results = UIResults.extractReplay(request);

WaybackRequest wbr = results.getWbRequest();
StringFormatter fmt = wbr.getFormatter();
CaptureSearchResult cResult = results.getResult();
ResultURIConverter uric = results.getURIConverter();

String sourceUrl = cResult.getOriginalUrl();
String targetUrl = cResult.getRedirectUrl();
String captureTS = cResult.getCaptureTimestamp();
Date captureDate = cResult.getCaptureDate();
String httpCode = cResult.getHttpCode();

if(targetUrl.equals("-")) {
    Map<String,String> headers = results.getResource().getHttpHeaders();
    Iterator<String> headerNameItr = headers.keySet().iterator();
    while(headerNameItr.hasNext()) {
           String name = headerNameItr.next();
           if(name.toUpperCase().equals("LOCATION")) {
                targetUrl = headers.get(name);
                // by the spec, these should be absolute already, but just in case:
                targetUrl = UrlOperations.resolveUrl(sourceUrl, targetUrl);
                
                
           }
    }
}
// TODO: Handle replay if we still don't have a redirect..
ArchivalUrl aUrl = new ArchivalUrl(wbr);
String dateSpec = aUrl.getDateSpec(captureTS);

String targetReplayUrl = uric.makeReplayURI(dateSpec,targetUrl);

String safeSource = fmt.escapeHtml(sourceUrl);
String safeTarget = fmt.escapeHtml(targetUrl);
String safeTargetJS = fmt.escapeJavaScript(targetUrl);
String safeTargetReplayUrl = fmt.escapeHtml(targetReplayUrl);
String safeTargetReplayUrlJS = fmt.escapeJavaScript(targetReplayUrl);
String safeHttpCode = fmt.escapeHtml(httpCode);

String prettyDate = fmt.format("{0,date,d MMM yyyy, H:mma}", captureDate).replace("AM", "am").replace("PM","pm");
int secs = 5;

%>
<jsp:include page="/WEB-INF/template/UI-header.jsp" flush="true" />
<body>

<div class="message info">
<h2>Just a moment, we are taking you to the webpage</h2>
<p><strong>At <%= prettyDate %></strong></p>
<p><%= safeSource %></p> 
<p><strong>redirected to</strong></p>
<p><%= safeTarget %></p>
<br/>
<p>In <span id="countdown"><%= secs %> seconds</span> we will redirect you to a snapshot of <%= safeTarget %></p>
<p class="impatient">or <a href="<%= safeTargetReplayUrl %>" target="replayFrame">Go there now</a></p>
<br/>
<hr/>
<p><a target="_blank" href="http://help.nla.gov.au/node/1282">Why am I seeing this?</a></p>
</div>

<script type="text/javascript">
function go() {
	document.location.href = "<%= safeTargetReplayUrlJS %>";
}

function countdown(element, seconds) {
    interval = setInterval(function() {
        var el = document.getElementById(element);
        seconds--;
        if(seconds == 0) {
            clearInterval(interval);
            //go();
        }

        var secondText = seconds == 1 ? 'second' : 'seconds';
        el.innerHTML = seconds + ' ' + secondText;
    }, 1000);
}

</script>
<jsp:include page="/WEB-INF/template/UI-footer.jsp" flush="true" />

<script>
countdown('countdown', <%= secs %>);
</script>