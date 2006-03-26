<html>
<head>
  <% require"cgilua.cookies"
     if cgi.user then
       cgilua.cookies.sethtml("Xavante", cgi.user)
     end
  %>
</head>
<body>
<title>CGILua test</title>
<b>Containment</b>:<br />
<% if (x == nil) then x = 1 else x = x + 1 end %>
Expected value = 1
<table>
  <tr>
    <td<% if x ~= 1 then cgilua.put([[ bgcolor="red"]]) end %>>
      Actual value = <%=x%>
    </td>
  </tr>
</table>
<br />
<br />
<b>Form Handling</b>:
<form method="post" action="test.lp">
User name: <input name="user" maxlength="20" size="20">
Password: <input name="pass" type="password" maxlength="20" size="20">
<input type="submit" value="Post it">
<input type="reset" value="Reset">
</form>
Values: Username = <%= cgi.user or ""%>, Password = <%= cgi.pass or ""%>
<br />
<br />
<b>Cookies</b>:<br />
Username = <%= cgilua.cookies.get("Xavante") or "" %><br />
<br />
<b>Server Variables</b>:<br />
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
<br />
<b>Date</b>:<br />
<%= os.date() %><br />
<br />
<b>Image test</b>:<img src="img/test.jpg"><br />
<br />
<b>Dir library</b>:<br />
<%
  local d = lfs.currentdir () or ""
  cgilua.put("Iterating over "..d.."<br />")
  for file in lfs.dir(d) do cgilua.put("&nbsp;&nbsp;&nbsp;"..file.."<br />") end
%>
<br />
</body>
</html>