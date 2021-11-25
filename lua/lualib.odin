package lua
import "core:c"
import "core:c/libc"

when ODIN_OS == "windows" { foreign import lib "../lua54.lib"    }
when ODIN_OS == "linux"   { foreign import lib "system:lua54" }
when ODIN_OS == "darwin"  { foreign import lib "system:lua54" }
when ODIN_OS == "freebsd" { foreign import lib "system:lua54" }

VERSUFFIX :: "_" + VERSION_MAJOR + "_" + VERSION_MINOR

@(default_calling_convention = "c", link_prefix="lua")
foreign lib { 
    open_base :: proc(L: ^State) -> c.int ---

    open_coroutine :: proc(L: ^State) -> c.int ---

    open_table :: proc(L: ^State) -> c.int ---

    open_io :: proc(L: ^State) -> c.int ---

    open_os :: proc(L: ^State) -> c.int ---

    open_string :: proc(L: ^State) -> c.int ---

    open_utf8 :: proc(L: ^State) -> c.int ---

    open_math :: proc(L: ^State) -> c.int ---

    open_debug :: proc(L: ^State) -> c.int ---

    open_package :: proc(L: ^State) -> c.int ---


    /* open all previous libraries */
    L_openlibs :: proc(L: ^State) ---
}

COLIBNAME: cstring : "coroutine"

TABLIBNAME: cstring : "table"

IOLIBNAME: cstring : "io"

OSLIBNAME: cstring : "os"

STRLIBNAME: cstring : "string"

UTF8LIBNAME: cstring : "utf8"

MATHLIBNAME: cstring : "math"

DBLIBNAME: cstring : "debug"

LOADLIBNAME: cstring : "package"