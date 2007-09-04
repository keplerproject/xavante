<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>CGILua Test</title>
    <link rel="stylesheet" href="css/doc.css" type="text/css"/>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <%
    require"cgilua.cookies"
    if cgilua.POST.user then
        cgilua.cookies.sethtml("cookie_kepler", cgilua.POST.user)
    end
    %>
</head>

<body>

<div id="container">

<div id="product">
	<div id="product_logo"><a href="http://www.keplerproject.org">
		<img src="img/keplerproject.gif" alt="Kepler Project logo" /></a>
    </div>
	<div id="product_name"><big><strong></strong></big></div>
	<div id="product_description">CGILua simple tests</div>
</div> <!-- id="product" -->

<div id="main">

<div id="navigation">
<% 
local mods = {}
for file in lfs.dir("doc") do
    local attr = lfs.attributes ("doc/"..file)
    if attr.mode == "directory" and file ~= "." and file ~= ".." then
        table.insert(mods, file)
    end
end
table.sort(mods)
%>

<h1>Kepler</h1>
	<ul>
        <li><a href="/">Documentation</a>
            <ul>
                <%
                for _,file in ipairs(mods) do
                %>
                <li><strong><a href="doc/<%= file %>/index.html"><%= file %></a></strong></li>
                <%
                end
                if not next(mods) then
                %>
                <li><strong>(None)</strong></li>
                <%
                end
                %>
            </ul>
        </li>
        <li><strong>Tests</strong></li>
	</ul>
</div> <!-- id="navigation" -->

<div id="content">


<h2>Form Handling</h2>

<p>
Entering values on this form should display them as values in the first submission,
and as a cookie in the next submission
</p>

<form method="post" action="test.lp">
<label>User name: </label><input name="user" maxlength="20" size="20">
<label>Password: </label><input name="pass" type="password" maxlength="20" size="20">
<input type="submit" value="Post it">
<input type="reset" value="Reset">
</form>

<p>
The values should show the previous POST
</p>

<p>
Values: Username = <%= cgilua.POST.user or "(not set)"%>, Password = <%= cgilua.POST.pass or "(not set)"%>
</p>

<h2>Cookies test</h2>

<p>
Here you should see the values posted before the ones shown above
</p>

<p>
cookie_kepler = <%= cgilua.cookies.get("cookie_kepler") or "(not set)" %>
</p>

<h2>Server Variables</h2>
<table border="1" cellpadding="5">
  <tr><td>SERVER_SOFTWARE</td><td><%= tostring(cgilua.servervariable("SERVER_SOFTWARE")) %></td></tr>
  <tr><td>SERVER_NAME</td><td><%= tostring(cgilua.servervariable("SERVER_NAME")) %></td></tr>
  <tr><td>GATEWAY_INTERFACE</td><td><%= tostring(cgilua.servervariable("GATEWAY_INTERFACE")) %></td></tr>
  <tr><td>SERVER_PROTOCOL</td><td><%= tostring(cgilua.servervariable("SERVER_PROTOCOL")) %></td></tr>
  <tr><td>SERVER_PORT</td><td><%= tostring(cgilua.servervariable("SERVER_PORT")) %></td></tr>
  <tr><td>REQUEST_METHOD</td><td><%= tostring(cgilua.servervariable("REQUEST_METHOD")) %></td></tr>
  <tr><td>PATH_INFO</td><td><%= tostring(cgilua.servervariable("PATH_INFO")) %></td></tr>
  <tr><td>PATH_TRANSLATED</td><td><%= tostring(cgilua.servervariable("PATH_TRANSLATED")) %></td></tr>
  <tr><td>SCRIPT_NAME</td><td><%= tostring(cgilua.servervariable("SCRIPT_NAME")) %></td></tr>
  <tr><td>QUERY_STRING</td><td><%= tostring(cgilua.servervariable("QUERY_STRING")) %></td></tr>
  <tr><td>REMOTE_HOST</td><td><%= tostring(cgilua.servervariable("REMOTE_HOST")) %></td></tr>
  <tr><td>REMOTE_ADDR</td><td><%= tostring(cgilua.servervariable("REMOTE_ADDR")) %></td></tr>
  <tr><td>REMOTE_PORT</td><td><%= tostring(cgilua.servervariable("REMOTE_PORT")) %></td></tr>
  <tr><td>AUTH_TYPE</td><td><%= tostring(cgilua.servervariable("AUTH_TYPE")) %></td></tr>
  <tr><td>REMOTE_USER</td><td><%= tostring(cgilua.servervariable("REMOTE_USER")) %></td></tr>
  <tr><td>REMOTE_IDENT</td><td><%= tostring(cgilua.servervariable("REMOTE_IDENT")) %></td></tr>
  <tr><td>CONTENT_TYPE</td><td><%= tostring(cgilua.servervariable("CONTENT_TYPE")) %></td></tr>
  <tr><td>CONTENT_LENGTH</td><td><%= tostring(cgilua.servervariable("CONTENT_LENGTH")) %></td></tr>
</table>

<h2>Date</h2>

<p>Today is: <%= os.date() %></p>

<h2>Image test</h2>

<p>Here should be a small image: <img src="img/test.jpg" alt="a small photograph" /></p>

<h2>FileSystem test</h2>

<p>
<%
  local d = lfs.currentdir () or ""
  cgilua.put("Iterating over "..d.."<br />")
  for file in lfs.dir(d) do cgilua.put("&nbsp;&nbsp;&nbsp;"..file.."<br />") end
%>
</p>

<h2>Containment test</h2>

<p>
<% if (x == nil) then x = 1 else x = x + 1 end %>
Expected value: 1, actual value: <%= x %>.
</p>


</div> <!-- id="content" -->

</div> <!-- id="main" -->

<div id="about">
	<p><a href="http://validator.w3.org/check?uri=referer">
    <img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0!" height="31" width="88" /></a></p>
	<p><small>$Id: test.lp,v 1.8 2007/09/04 19:49:49 carregal Exp $</small></p>
</div> <!-- id="about" -->

</div> <!-- id="container" -->
</body>
</html>
