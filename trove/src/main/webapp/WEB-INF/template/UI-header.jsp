<!doctype html>
<%@ page import="org.archive.wayback.core.WaybackRequest" %>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%
UIResults results = UIResults.getGeneric(request);
WaybackRequest wbRequest = results.getWbRequest();
StringFormatter fmt = wbRequest.getFormatter();

String staticPrefix = results.getStaticPrefix();
String queryPrefix = results.getQueryPrefix();
String replayPrefix = results.getReplayPrefix();
response.setHeader("X-MadeUp-Header", "Yes");
%>
<!-- HEADER -->
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />

<link rel="stylesheet" type="text/css" 
    href="<%= staticPrefix %>css/styles.css"
    src="<%= staticPrefix %>css/styles.css" />
<script type="text/javascript" src="<%= staticPrefix %>js/jquery-1.4.2.min.js"></script>
<title><%= fmt.format("UIGlobal.pageTitle") %></title>
<base target="_top" />
</head>

<body bgcolor="white" alink="red" vlink="#0000aa" link="blue" 
style="font-family: Arial; font-size: 10pt"> 
<!-- /HEADER -->
