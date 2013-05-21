<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="org.archive.wayback.core.UIResults"%>
<%
UIResults results = UIResults.extractReplay(request);
String staticPrefix = results.getStaticPrefix();
%>
<script type="text/javascript" src="<%= staticPrefix %>js/nla-web-archive.js"></script>
<script type="text/javascript">
_NationalLibraryOfAustralia_WebArchive.postMessage({type: 'state', data: 'resourceFound'});
</script>

