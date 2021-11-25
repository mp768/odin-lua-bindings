/*
** $Id: lauxlib.h $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/
package lua
import "core:c"
import "core:c/libc"
import "core:fmt"

when ODIN_OS == "windows" { foreign import lib "../lua54.lib"    }
when ODIN_OS == "linux"   { foreign import lib "system:lua54" }
when ODIN_OS == "darwin"  { foreign import lib "system:lua54" }
when ODIN_OS == "freebsd" { foreign import lib "system:lua54" }


/* global table */
L_GNAME: cstring : "_G"

L_Buffer :: struct {
    b: cstring,  /* buffer address */
    size: c.size_t,  /* buffer size */
    n: c.size_t,  /* number of characters in buffer */
    L: ^State,
    init: struct #raw_union {
      n: Number, u: c.double, s: rawptr, i: Integer, l: c.long, /* ensure maximum alignment for buffer */
      b: [L_BUFFERSIZE]c.char, /* initial buffer */
    },
}


/* extra error code for 'luaL_loadfilex' */
L_ERRFILE :: (ERRERR+1)


/* key, in the registry, for table of loaded modules */
L_LOADED_TABLE: cstring : "_LOADED"


/* key, in the registry, for table of preloaded loaders */
L_PRELOAD_TABLE: cstring :"_PRELOAD"

L_Reg :: struct {
  name: cstring,
  func: CFunction,
}

NUMSIZES :: (size_of(Integer)*16 + size_of(Number))

/* predefined references */
NOREF  :: (-2)
REFNIL :: (-1)

@(default_calling_convention = "c", link_prefix="lua")
foreign lib {
    L_checkversion_ :: proc(L: ^State, ver: Number, sz: c.size_t) ---

    L_getmetafield :: proc(L: ^State, obj: c.int, e: cstring) -> c.int ---
    L_callmeta :: proc(L: ^State, obj: c.int, e: cstring) -> c.int ---
    L_tolstring :: proc(L: ^State, idx: c.int, len: ^c.size_t) -> cstring ---
    L_argerror :: proc(L: ^State, arg: c.int, extramsg: cstring) -> c.int ---
    L_typeerror :: proc(L: ^State, arg: c.int, tname: cstring) -> c.int ---
    L_checklstring :: proc(L: ^State, arg: c.int, l: ^c.size_t) -> cstring ---

    L_optlstring :: proc(L: ^State, arg: c.int, def: cstring, l: ^c.size_t) -> cstring ---
    
    L_checknumber :: proc(L: ^State, arg: c.int) -> Number ---
    L_optnumber :: proc(L: ^State, arg: c.int, def: Number) -> Number ---

    L_checkinteger :: proc(L: ^State, arg: c.int) -> Integer ---
    L_optinteger :: proc(L: ^State, arg: c.int, def: Integer) -> Integer ---

    L_checkstack :: proc(L: ^State, sz: c.int, msg: cstring) ---
    L_checktype :: proc(L: ^State, arg: c.int, t: c.int) ---
    L_checkany :: proc(L: ^State, arg: c.int) ---

    L_newmetatable :: proc(L: ^State, tname: cstring) -> c.int ---
    L_setmetatable :: proc(L: ^State, tname: cstring) ---
    L_testudata :: proc(L: ^State, ud: c.int, tname: cstring) -> rawptr ---
    L_checkudata :: proc(L: ^State, ud: c.int, tname: cstring) -> rawptr ---

    L_where :: proc(L: ^State, lvl: c.int) ---
    L_error :: proc(L: ^State, fmt: cstring, _: ..any) -> c.int ---

    L_checkoption :: proc(L: ^State, arg: c.int, def: cstring, lst: []cstring) -> c.int ---

    L_fileresult :: proc(L: ^State, state: c.int, fname: cstring) -> c.int ---
    L_execresult :: proc(L: ^State, state: c.int) -> c.int ---


    L_ref :: proc(L: ^State, t: c.int) -> c.int ---
    L_unref :: proc(L: ^State, t: c.int, ref: c.int) ---

    L_loadfilex :: proc(L: ^State, filename: cstring, mode: cstring) -> c.int ---

    L_loadbufferx :: proc(L: ^State, buff: cstring, sz: c.size_t, name: cstring, mode: cstring) -> c.int ---
    L_loadstring :: proc(L: ^State, s: cstring) -> c.int ---

    L_newstate :: proc() -> ^State ---

    L_len :: proc(L: ^State, idx: c.int) -> Integer ---

    L_addgsub :: proc(b: ^L_Buffer, s: cstring, p: cstring, r: cstring) ---
    L_gsub :: proc(L: ^State, s: cstring, p: cstring, r: cstring) -> cstring ---

    L_setfuncs :: proc(L: ^State, l: ^L_Reg, nup: c.int) ---

    L_getsubtable :: proc(L: ^State, idx: c.int, fname: cstring) -> c.int ---

    L_traceback :: proc(L: ^State, L1: ^State, msg: cstring, level: c.int) ---

    L_requiref :: proc(L: ^State, modname: cstring, openf: CFunction, glb: c.int) ---

    /*
    ** Generic Buffer manipulation
    */
    L_buffinit :: proc (L: ^State, B: ^L_Buffer) ---
    L_prepbuffsize :: proc (B: ^L_Buffer, sz: c.size_t) -> ^c.char ---
    L_addlstring :: proc (B: ^L_Buffer, s: cstring, l: c.size_t) ---
    L_addstring :: proc (B: ^L_Buffer, s: cstring) ---
    L_addvalue :: proc (B: ^L_Buffer) ---
    L_pushresult :: proc (B: ^L_Buffer) ---
    L_pushresultsize :: proc (B: ^L_Buffer, sz: c.size_t) ---
    L_buffinitsize :: proc (L: ^State, B: ^L_Buffer, sz: c.size_t) -> ^c.char ---
}

/*
** lua macro conversions
*/
L_checkversion :: #force_inline proc(L: ^State) { L_checkversion_(L, VERSION_NUM, NUMSIZES) }
L_loadfile :: #force_inline proc(L: ^State, f: cstring) -> bool {	return bool(L_loadfilex(L,f,nil)) }

//L_newlibtable :: #force_inline proc(L: ^State, l)	createtable(L, 0, sizeof(l)/sizeof((l)[0]) - 1)

//#define luaL_newlib(L,l)  \
//  (luaL_checkversion(L), luaL_newlibtable(L,l), luaL_setfuncs(L,l,0))

L_argcheck :: #force_inline proc(L: ^State, cond: bool, arg: c.int, extramsg: cstring) -> bool { return (cond) || bool(L_argerror(L, (arg), (extramsg))) }
L_argexpected :: #force_inline proc(L: ^State, cond: bool, arg: c.int, tname: cstring) -> bool { return (cond) || bool(L_typeerror(L, (arg), (tname))) }

L_checkstring :: #force_inline proc(L: ^State, n: c.int) -> cstring	{ return L_checklstring(L, (n), nil) }
L_optstring :: #force_inline proc(L: ^State, n: c.int, d: cstring) -> cstring 	{ return L_optlstring(L, (n), (d), nil) }

L_typename :: #force_inline proc(L: ^State, i: c.int) -> cstring { return typename(L, type(L,(i))) }

L_dofile :: #force_inline proc(L: ^State, fn: cstring) -> bool { return bool(L_loadfile(L, fn)) || bool(pcall(L, 0, MULTIRET, 0)) }
L_dostring :: #force_inline proc(L: ^State, s: cstring) -> bool { return bool(L_loadstring(L, s)) || bool(pcall(L, 0, MULTIRET, 0)) }

L_getmetatable :: #force_inline proc(L: ^State, n: cstring) -> c.int { return getfield(L, REGISTRYINDEX, (n)) }

//L_opt(L: ^State, f: CFunction, n: c.int, d: c.int) (isnoneornil(L,(n)) ? (d) : f(L,(n)))

L_loadbuffer :: #force_inline proc (L: ^State, s: cstring, sz: c.size_t, n: cstring) -> bool { return bool(L_loadbufferx(L,s,sz,n,nil)) }

/* push the value used to represent failure/error */
L_pushfail :: #force_inline proc(L: ^State)	{ pushnil(L) }
