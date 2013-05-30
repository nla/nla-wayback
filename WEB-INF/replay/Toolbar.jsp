<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="org.archive.wayback.core.UIResults"%>
<%@ page import="org.springframework.util.PropertyPlaceholderHelper"%>
<%@ page import="java.util.Properties"%>
<%
UIResults results = UIResults.extractReplay(request);
String staticPrefix = results.getStaticPrefix();

PropertyPlaceholderHelper placeholderHelper = new PropertyPlaceholderHelper("${","}");
Properties agwaProperties = new Properties();
agwaProperties.load(application.getResourceAsStream("/WEB-INF/agwa.properties"));

String agwaBaseUrl = placeholderHelper.replacePlaceholders(agwaProperties.getProperty("agwa.url.base"), agwaProperties);
String agwaPrefixQueryUrl = placeholderHelper.replacePlaceholders(agwaProperties.getProperty("agwa.url.search.prefix"), agwaProperties);
%>
<script type="text/javascript" src="<%= staticPrefix %>js/nla-web-archive.js"></script>
<script type="text/javascript">
_NationalLibraryOfAustralia_WebArchive.setBaseUrl('<%= agwaBaseUrl %>');
_NationalLibraryOfAustralia_WebArchive.setPrefixQueryUrl('<%= agwaPrefixQueryUrl %>');
_NationalLibraryOfAustralia_WebArchive.postMessage({type: 'state', data: 'resourceFound'});
</script>

