<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"
%><%@ page import="org.archive.wayback.core.UIResults"
%>
<!-- The next two imports are required for loading the file agwa.properties -->
  <%@ page import="org.springframework.util.PropertyPlaceholderHelper"
%><%@ page import="java.util.Properties"
%>
<%
UIResults results = UIResults.extractReplay(request);
String staticPrefix = results.getStaticPrefix();

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

%>
<script type="text/javascript" src="<%= staticPrefix %>js/nla-web-archive.js"></script>
<script type="text/javascript">
;(function(){
    var agwaWayback = _NationalLibraryOfAustralia_WebArchive;
    agwaWayback.setAgwaUrl('<%= session.getAttribute("agwaUrl") %>');
    agwaWayback.setWaybackUrl('<%= session.getAttribute("waybackUrl") %>');
    agwaWayback.setPrefixQueryUrl('<%= session.getAttribute("agwaPrefixQueryUrl") %>');    
    agwaWayback.postMessage({type: 'state', data: 'resourceFound'});
})();
</script>
<!-- agwaUrl = <%= session.getAttribute("agwaUrl") %> -->
