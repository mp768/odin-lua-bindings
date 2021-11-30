# odin-lua-bindings
This is a set of bindings of the lua library for the lua programming language created for a programming language called "odin"

@(Note): I've only tested this on windows.

# how to use
well simply all you need is the 'lua' folder and the lua library, and just import the package.
The naming conventions stay the same, and just require the 'lua.' to access.

here's how a simple program can be done.

main.odin:
```Odin
package main
import "lua"

main :: proc() {
  LuaState := lua.L_newstate()
  
  lua.L_openlibs(LuaState)
  
  lua.L_dofile(LuaState, "test.lua")
  
  lua.close(LuaState)
}
```

test.lua:
```Lua
print("Hello, from lua!")
```
