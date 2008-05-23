package = "Xavante"

version = "2.0.0-1"

source = {
  url = "",
}

description = {
  summary = "Lua Web Server Library",
  detailed = [[
    Xavante is a Lua HTTP 1.1 Web server that uses a modular architecture based on URI mapped handlers.
    This rock installs Xavante as a library that other applications can use.
  ]],
  license = "MIT/X11",
  homepage = "http://www.keplerproject.org/xavante"
}

dependencies = { 'luasocket >= 2.0.2', 'copas >= 1.1.3', 'luafilesystem >= 1.4.1' }

build = {
   type = "make",
   build_pass = false,
   install_target = "install",
   install_variables = {
     LUA_DIR = "$(LUADIR)",
   }
}
