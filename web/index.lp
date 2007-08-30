<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>Welcome!</title>
</head>

<body>
<div style="text-align: center;">
<img src = "img/keplerproject.gif" alt="Kepler Project logo"/>

<h1>Welcome!</h1>
<p>
If you are reading this page,
<strong><%= cgilua.servervariable("SERVER_SOFTWARE") %></strong>
has been successfully installed on your system.
</p>
<p>From here you can run some <a href="test.lp">tests</a>.</p>
<p>
Copyright 2004-2007 - <a href="http://www.keplerproject.org">Kepler Project</a>
</p>
</div>
</body>
</html>