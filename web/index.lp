<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Welcome to Xavante!</title>
</head>

<body>
<center>
<img src = "/img/xavante.gif" />
<h1>Welcome to Xavante!</h1>
If you are reading this page, <strong><%= cgilua.servervariable("SERVER_SOFTWARE") %></strong>
has been successfully installed on your system.<br />
<br />
From here you can browse the <a href="/doc/index.html">Xavante documentation</a>
 or run some <a href="test.lp">Xavante tests</a>. <br />
<br />
Copyright 2004-2005 - <a href="http://www.keplerproject.org">Kepler Project</a><br />
</center>
</body>
</html>