package lua
import "core:fmt"
import "core:c"

main :: proc() {
    L := L_newstate()

    L_openlibs(L)

    L_dofile(L, "test.lua")

    close(L)
}