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
%><%@page import="org.archive.wayback.exception.SpecificCaptureReplayException"
%><%
UIResults results = UIResults.extractException(request);
WaybackException e = results.getException();
WaybackRequest wbr = results.getWbRequest();
e.setupResponse(response);
String staticPrefix = wbr.getAccessPoint().getStaticPrefix();
String queryPrefix = wbr.getAccessPoint().getQueryPrefix();
String replayPrefix = wbr.getAccessPoint().getReplayPrefix();
String requestUrl = wbr.getRequestUrl();

StringFormatter fmt = results.getWbRequest().getFormatter();

String notArchivedRedirectUrl = null;
// Added by Tomas
// redirect to pandora's "not archived" web page 
if(e instanceof ResourceNotInArchiveException) {
	if (requestUrl.lastIndexOf("/") <= 8 && wbr.getReplayTimestamp().length() > 0) {
		// no slash after http://, let's try to redirect to /index.html
		notArchivedRedirectUrl = replayPrefix + wbr.getReplayTimestamp() + "/" + requestUrl + "/index.html";
	} else if (requestUrl.endsWith("/") && wbr.getReplayTimestamp().length() > 0) {
		// let's try to redirect to /index.html
		notArchivedRedirectUrl = replayPrefix + wbr.getReplayTimestamp() + "/" + requestUrl + "index.html";
	} else {
		// give up :)
		// strip the server context (e.g. /nph-wb/)
		 int stripMe = replayPrefix.indexOf("/", 9);
		 if (stripMe != -1) {
			 notArchivedRedirectUrl = replayPrefix.substring(0, stripMe) + "/external.html?link=" + requestUrl;
		 } else {
			 notArchivedRedirectUrl = replayPrefix + "/external.html?link=" + requestUrl;
		 }
	}
	response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
	response.setHeader("Location", notArchivedRedirectUrl);
}
%>

	<jsp:include page="/WEB-INF/template/UI-header.jsp" flush="true">
		<jsp:param name="metaRedirectExternalTo" value="<%= notArchivedRedirectUrl %>" />
	</jsp:include>

        <div id="positionHome">
            <section>
            <div id="error">

                <h2><%= fmt.format(e.getTitleKey()) %></h2>
                <p><%= fmt.format(e.getMessageKey(),e.getMessage()) %></p>
<%
if(e instanceof ResourceNotInArchiveException) {
	ResourceNotInArchiveException niae = (ResourceNotInArchiveException) e;
	List<String> closeMatches = niae.getCloseMatches();
%>
<h3>Page not found. You're being redirected to <a href="<%= notArchivedRedirectUrl %>"><%= notArchivedRedirectUrl %></a></h3>
<script type="text/javascript">
	document.location.href = "<%= notArchivedRedirectUrl %>";
</script>
<%
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
            </section>
            <div id="errorBorder"></div>

<jsp:include page="/WEB-INF/template/UI-footer.jsp" flush="true" />
