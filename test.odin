package main
import "lua"

main :: proc() {
    state := lua.L_newstate()

    lua.L_openlibs(state)

    lua.L_dofile(state, "test.lua")

    lua.close(state)
}