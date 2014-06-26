<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.Date" %>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%
UIResults results = UIResults.extractReplay(request);
StringFormatter fmt = results.getWbRequest().getFormatter();
Date exactDate = results.getResult().getCaptureDate();
Date now = new Date();
String prettyDateFormat = "{0,date,H:mm:ss MMM d, yyyy}";
String prettyArchiveString = fmt.format(prettyDateFormat,exactDate);
String prettyRequestString = fmt.format(prettyDateFormat,now);
%>
<!--
     FILE ARCHIVED ON <%= prettyArchiveString %> AND RETRIEVED FROM THE
     NLA PANDORA ARCHIVE ON <%= prettyRequestString %>.
     JAVASCRIPT APPENDED BY WAYBACK MACHINE, COPYRIGHT INTERNET ARCHIVE.

     CONTENT OF THE DISPLAYED PAGE IS SUBJECT TO COPYRIGHT AS HELD BY 
     THE ORIGINAL AUTHORS AND/OR PUBLISHERS.
-->
<!-- Google analytics for PANDORA web archive -->
<script>
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','__auGovNlaPandoraAnalytics');
__auGovNlaPandoraAnalytics('create', 'UA-807909-23', 'nla.gov.au');
__auGovNlaPandoraAnalytics('send', 'pageview');
</script>
<!-- /Google analytics for PANDORA web archive -->
