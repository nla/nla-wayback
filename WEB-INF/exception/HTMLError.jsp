<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"
%><%@ page import="java.util.List"
%><%@ page import="java.util.Date"
%><%@ page import="java.util.Iterator"
%><%@ page import="org.archive.wayback.exception.WaybackException"
%><%@ page import="org.archive.wayback.ResultURIConverter"
%><%@ page import="org.archive.wayback.exception.ResourceNotInArchiveException"
%><%@ page import="org.archive.wayback.core.CaptureSearchResult"
%><%@ page import="org.archive.wayback.core.CaptureSearchResults"
%><%@ page import="org.archive.wayback.core.UIResults"
%><%@ page import="org.archive.wayback.core.WaybackRequest"
%><%@ page import="org.archive.wayback.util.StringFormatter"
%><%@ page import="org.archive.wayback.util.url.UrlOperations"
%><%@ page import="org.archive.wayback.partition.PartitionsToGraph"
%><%@ page import="org.archive.wayback.util.partition.Partitioner"
%><%@ page import="org.archive.wayback.util.partition.Partition"
%><%@ page import="org.archive.wayback.util.partition.PartitionSize"
%><%@ page import="org.archive.wayback.partition.PartitionPartitionMap"
%><%@ page import="org.archive.wayback.exception.SpecificCaptureReplayException"
%>
<!-- The next two imports are required for loading the file agwa.properties -->
  <%@ page import="org.springframework.util.PropertyPlaceholderHelper"
%><%@ page import="java.util.Properties"
%>
<%
// Load the config file 'agwa.properties' to figure out where AGWA lives in 
// order to integrate with it

PropertyPlaceholderHelper placeholderHelper;
Properties agwaProperties;

if (session.getAttribute("agwaPropertiesLoaded") == null) {
    placeholderHelper = new PropertyPlaceholderHelper("${", "}");
    agwaProperties = new Properties();
    agwaProperties.load(application.getResourceAsStream("/WEB-INF/agwa.properties"));
    session.setAttribute("agwaUrl", placeholderHelper.replacePlaceholders(agwaProperties.getProperty("agwa.url"), agwaProperties));
    session.setAttribute("waybackUrl", placeholderHelper.replacePlaceholders(agwaProperties.getProperty("wayback.url"), agwaProperties));
    session.setAttribute("agwaPrefixQueryUrl", placeholderHelper.replacePlaceholders(agwaProperties.getProperty("agwa.url.search.prefix"), agwaProperties));
    session.setAttribute("agwaPropertiesLoaded", true);
}

UIResults results = UIResults.extractException(request);
WaybackException e = results.getException();
WaybackRequest wbr = results.getWbRequest();
e.setupResponse(response);
String staticPrefix = wbr.getAccessPoint().getStaticPrefix();
String queryPrefix = wbr.getAccessPoint().getQueryPrefix();
String replayPrefix = wbr.getAccessPoint().getReplayPrefix();
String requestUrl = wbr.getRequestUrl();

StringFormatter fmt = results.getWbRequest().getFormatter();
%>
<script type="text/javascript" src="<%= staticPrefix %>js/nla-web-archive.js"></script>
<jsp:include page="/WEB-INF/template/UI-header.jsp" flush="true" />

<div class="message error">
<h2><%= fmt.format(e.getTitleKey()) %></h2>
<p><%= fmt.format(e.getMessageKey(),e.getMessage()) %></p>
<%
if(e instanceof ResourceNotInArchiveException) {
	ResourceNotInArchiveException niae = (ResourceNotInArchiveException) e;
	List<String> closeMatches = niae.getCloseMatches();
	if(closeMatches != null && !closeMatches.isEmpty()) {
%>
		        <p>Other possible close matches to try:</p>
		        <p>
<%
		WaybackRequest tmp = wbr.clone();
		for(String closeMatch : closeMatches) {
			tmp.setRequestUrl(closeMatch);
			String link = queryPrefix + "query?" +
				tmp.getQueryArguments();
%>
			    <a href="<%= link %>"><%= closeMatch %></a><br/>
<%
		}
	}
	String parentUrl = UrlOperations.getUrlParentDir(requestUrl);
	if(parentUrl != null) {
		String escapedParentUrl = fmt.escapeHtml(parentUrl); 		
		String prefixQueryUrl = ((String)session.getAttribute("agwaPrefixQueryUrl")).replace("{{URL}}", escapedParentUrl);
		String escapedPrefixQueryUrl = fmt.escapeHtml(prefixQueryUrl);
		%>
		        </p>
		        <p>More options:</p>
			    <%-- <p>Try Searching all pages under <a href="<%= escapedLink %>"><%= escapedParentUrl %></a></p> --%>
			    <p>Try searching all pages under <a href="<%= escapedPrefixQueryUrl %>"><%= escapedParentUrl %></a></p>
		<%
	}
} else if(e instanceof SpecificCaptureReplayException) {
	%>
	        <div class="wm-nav-link-div">
	        <%
	        SpecificCaptureReplayException scre = (SpecificCaptureReplayException) e;

	        CaptureSearchResult prev = scre.getPreviousResult();
	        CaptureSearchResult next = scre.getNextResult();
	        String dateFormat = "{0,date,MMMM dd, yyyy HH:mm:ss}";
	        ResultURIConverter conv = wbr.getAccessPoint().getUriConverter();
	        if((prev != null) && (next != null)) {
	                String safePrevReplay = fmt.escapeHtml(conv.makeReplayURI(prev.getCaptureTimestamp(),prev.getOriginalUrl()));
	                String safeNextReplay = fmt.escapeHtml(conv.makeReplayURI(next.getCaptureTimestamp(),next.getOriginalUrl()));
	                %>
	                Would you like to try the <a href="<%= safePrevReplay %>">previous</a> or <a href="<%= safeNextReplay %>">next</a> date?
	                <%
	        } else if (prev != null) {
	                String safePrevReplay = fmt.escapeHtml(conv.makeReplayURI(prev.getCaptureTimestamp(),prev.getOriginalUrl()));
	                %>
	                Would you like to try the <a href="<%= safePrevReplay %>">previous</a> date?
	                <%

	        } else if (next != null) {
	                String safeNextReplay = fmt.escapeHtml(conv.makeReplayURI(next.getCaptureTimestamp(),next.getOriginalUrl()));
	                %>
	                Would you like to try the <a href="<%= safeNextReplay %>">next</a> date?
	                <%
	        }
	        %>
	        </div>
	<%
}
%>

            </div>
<script type="text/javascript">
;(function(){
    var agwaWayback = _NationalLibraryOfAustralia_WebArchive;
    agwaWayback.setAgwaUrl('<%= session.getAttribute("agwaUrl") %>');
    agwaWayback.setWaybackUrl('<%= session.getAttribute("waybackUrl") %>');
    agwaWayback.setPrefixQueryUrl('<%= session.getAttribute("agwaPrefixQueryUrl") %>');    
    if (agwaWayback.windowParentIsBrowserWindow()) {
        agwaWayback.resourceNotFound();
    } else {
        var msgBox = document.getElementsByClassName('message error')[0];
        msgBox.style.position = 'relative';
        msgBox.style.marginLeft = '0';
        msgBox.style.left = '0';
        msgBox.style.top = '0';
        msgBox.style.width = '300px';
        msgBox.style.fontSize = '60%';
    }
})();
</script>
<jsp:include page="/WEB-INF/template/UI-footer.jsp" flush="true" />
