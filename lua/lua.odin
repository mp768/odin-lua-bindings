/*
** $Id: lua.h $
** Lua - A Scripting Language
** Lua.org, PUC-Rio, Brazil (http://www.lua.org)
** See Copyright Notice at the end of this file
*/

package lua
import "core:c"
import "core:c/libc"

when ODIN_OS == "windows" { foreign import lib "../lua54.lib"    }
when ODIN_OS == "linux"   { foreign import lib "system:lua54" }
when ODIN_OS == "darwin"  { foreign import lib "system:lua54" }
when ODIN_OS == "freebsd" { foreign import lib "system:lua54" }

VERSION_MAJOR: cstring : "5"
VERSION_MINOR: cstring : "4"
VERSION_RELEASE: cstring : "2"

VERSION_NUM :: 504
VERSION_RELEASE_NUM :: VERSION_NUM * 100

VERSION: cstring : "Lua " + VERSION_MAJOR + "." + VERSION_MINOR
RELEASE: cstring : VERSION + "." + VERSION_RELEASE
COPYRIGHT: cstring : RELEASE + "  Copyright (C) 1994-2020 Lua.org, PUC-Rio"
AUTHORS: cstring : "R. Ierusalimschy, L. H. de Figueiredo, W. Celes"

/* mark for precompiled code ('<esc>Lua') */
SIGNATURE: cstring : "\x1bLua"

/* option for multiple returns in 'lua_pcall' and 'lua_call' */
MULTIRET :: -1

/*
** Pseudo-indices
** (-LUAI_MAXSTACK is the minimum valid index; we keep some free empty
** space after that to help overflow detection)
*/
REGISTRYINDEX :: (-MAXSTACK - 1000)
upvalueindex :: #force_inline proc(i: int) -> int { return (REGISTRYINDEX - (i)) }

OK :: 0
YIELD :: 1
ERRRUN :: 2
ERRSYNTAX :: 3
ERRMEM :: 4
ERRERR :: 5


State :: struct {}

/*
** basic types
*/
TNONE :: -1

TNIL :: 0
TBOOLEAN :: 1
TLIGHTUSERDATA :: 2
TNUMBER :: 3
TSTRING :: 4
TTABLE :: 5
TFUNCTION :: 6
TUSERDATA :: 7
TTHREAD :: 8

NUMTYPES :: 9

/* minimum Lua stack available to a C function */
MINSTACK :: 20


/* predefined values in the registry */
RIDX_MAINTHREAD :: 1
RIDX_GLOBALS    :: 2
RIDX_LAST       :: RIDX_GLOBALS

Number :: f64
Integer :: i64
Unsigned :: u64
KContext :: uintptr

/*
** Type for C functions registered with Lua
*/
CFunction :: proc(L: ^State) -> int 

/*
** Type for continuation functions
*/
KFunction :: proc(L: ^State, status: c.int, ctx: KContext) -> int

/*
** Type for functions that read/write blocks when loading/dumping Lua chunks
*/
Reader :: proc(L: ^State, ud: rawptr, sz: ^uintptr) -> cstring

Writer :: proc(L: ^State, p: rawptr, sz: uintptr, ud: rawptr) -> int

/*
** Type for memory-allocation functions
*/
Alloc :: proc(ud: rawptr, ptr: rawptr, osize: uintptr, nsize: uintptr) -> rawptr

/*
** Type for warning functions
*/
WarnFunction :: proc(ud: rawptr, msg: cstring, tocont: c.int)


@(default_calling_convention = "c", link_prefix="lua_")
foreign lib {
    /*
    ** state manipulation
    */
    newstate :: proc (f: Alloc, ud: rawptr) -> ^State ---
    close :: proc (L: ^State) ---
    newthread :: proc (L: ^State) -> ^State ---
    resetthread :: proc (L: ^State) -> c.int ---

    atpanic :: proc (L: ^State, panicf: CFunction) -> CFunction ---

    version :: proc(L: ^State) -> Number ---
    
    /*
    ** basic stack manipulation
    */
    absindex :: proc (L: ^State, idx: c.int) -> c.int ---
    gettop :: proc (L: ^State) -> c.int ---
    settop :: proc (L: ^State, idx: c.int) ---
    pushvalue :: proc (L: ^State, idx: c.int) ---
    rotate :: proc (L: ^State, idx: c.int, n: c.int) ---
    copy :: proc (L: ^State, fromidx: c.int, toidx: c.int) ---
    checkstack :: proc (L: ^State, n: c.int) -> c.int ---

    xmove :: proc(from: ^State, to: ^State, n: c.int) ---


    /*
    ** access functions (stack -> C)
    */
    isnumber :: proc(L: ^State, idx: c.int) -> c.int ---
    isstring :: proc(L: ^State, idx: c.int) -> c.int ---
    iscfunction :: proc(L: ^State, idx: c.int) -> c.int ---
    isinteger :: proc(L: ^State, idx: c.int) -> c.int ---
    isuserdata :: proc(L: ^State, idx: c.int) -> c.int ---
    type :: proc(L: ^State, idx: c.int) -> c.int ---
    typename :: proc(L: ^State, tp: c.int) -> cstring ---

    tonumberx :: proc(L: ^State, idx: c.int, isnum: ^c.int) -> Number ---
    tointegerx :: proc(L: ^State, idx: c.int, isnum: ^c.int) -> Integer ---
    toboolean :: proc(L: ^State, idx: c.int) -> c.int ---
    tolstring :: proc(L: ^State, idx: c.int, len: ^c.size_t) -> cstring ---
    rawlen :: proc(L: ^State, idx: c.int) -> Unsigned ---
    tocfunction :: proc(L: ^State, idx: c.int) -> CFunction ---
    touserdata :: proc(L: ^State, idx: c.int) -> rawptr ---
    tothread :: proc(L: ^State, idx: c.int) -> ^State ---
    topointer :: proc(L: ^State, idx: c.int) -> rawptr ---

    /*
    ** Comparison and arithmetic functions
    */
    arith :: proc(L: ^State, op: c.int) ---
    rawequal :: proc(L: ^State, idx1: c.int, idx2: c.int) -> c.int ---
    compare :: proc(L: ^State, idx1: c.int, idx2: c.int, op: c.int) -> c.int ---

    /*
    ** push functions (C -> stack)
    */
    pushnil :: proc(L: ^State) ---
    pushnumber :: proc(L: ^State, n: Number) ---
    pushinteger :: proc(L: ^State, n: Integer) ---
    pushlstring :: proc(L: ^State, s: cstring, len: c.size_t) -> cstring ---
    pushstring :: proc(L: ^State, s: cstring) -> cstring ---
    pushvfstring :: proc(L: ^State, fmt: cstring, argp: libc.va_list) -> cstring ---

    pushfstring :: proc(L: ^State, fmt: cstring, _: ..any) -> cstring ---
    pushcclosure :: proc(L: ^State, fn: CFunction, n: c.int) ---
    pushboolean :: proc(L: ^State, b: c.int) ---
    pushlightuserdata :: proc(L: ^State, p: rawptr) ---
    pushthread :: proc(L: ^State) -> c.int ---

    /*
    ** get functions (Lua -> stack)
    */
    getglobal :: proc(L: ^State, name: cstring) -> c.int ---
    gettable :: proc(L: ^State, idx: c.int) -> c.int ---
    getfield :: proc(L: ^State, idx: c.int, k: cstring) -> c.int ---
    geti :: proc(L: ^State, idx: c.int, n: Integer) -> c.int ---
    rawget :: proc(L: ^State, idx: c.int) -> c.int ---
    rawgeti :: proc(L: ^State, idx: c.int, n: Integer) -> c.int ---
    rawgetp :: proc(L: ^State, idx: c.int, p: rawptr) -> c.int ---

    createtable :: proc(L: ^State, narr: c.int, nrec: c.int) ---
    newuserdatauv :: proc(L: ^State, sz: c.size_t, nuvalue: c.int) -> rawptr ---
    getmetatable :: proc(L: ^State, objindex: c.int) -> c.int ---
    getiuservalue :: proc(L: ^State, idx: c.int, n: c.int) -> c.int ---

    /*
    ** set functions (stack -> Lua)
    */
    setglobal :: proc(L: ^State, name: cstring) ---
    settable :: proc(L: ^State, idx: c.int) ---
    setfield :: proc(L: ^State, idx: c.int, k: cstring) ---
    seti :: proc(L: ^State, idx: c.int, n: Integer) ---
    rawset :: proc(L: ^State, idx: c.int) ---
    rawseti :: proc(L: ^State, idx: c.int, n: Integer) ---
    rawsetp :: proc(L: ^State, idx: c.int, p: cstring) ---
    setmetatable :: proc(L: ^State, objindex: c.int) -> c.int ---
    setiuservalue :: proc(L: ^State, idx: c.int, n: c.int) -> c.int ---

    /*
    ** 'load' and 'call' functions (load and run Lua code)
    */
    callk :: proc(L: ^State, nargs: c.int, nresults: c.int, ctx: KContext, k: KFunction) ---

    pcallk :: proc(L: ^State, nargs: c.int, nresults: c.int, errfunc: c.int, ctx: KContext, k: KFunction) -> c.int ---

    load :: proc(L: ^State, reader:  Reader, dt: rawptr, chunkname: cstring, mode: cstring) -> c.int ---

    dump :: proc(L: ^State, writer: Writer, data: rawptr, strip: c.int) -> c.int ---

    /*
    ** coroutine functions
    */
    yieldk :: proc(L: ^State, nresults: c.int, ctx: KContext, k: KFunction) -> c.int ---
    resume :: proc(L: ^State, from: ^State, narg: c.int, nres: ^c.int) -> c.int ---
    status :: proc(L: ^State) -> c.int ---
    isyieldable :: proc(L: ^State) -> c.int ---

    /*
    ** Warning-related functions
    */
    setwarnf :: proc(L: ^State, f: WarnFunction, ud: rawptr) ---
    warning :: proc(L: ^State, msg: cstring, tocont: c.int) ---

    /*
    ** garbage-collection function
    */
    gc :: proc(L: ^State, what: c.int, _: ..any) -> c.int ---

    /*
    ** miscellaneous functions
    */

    error :: proc(L: ^State) -> c.int ---

    next :: proc(L: ^State, idx: c.int) -> c.int ---

    concat :: proc(L: ^State, n: c.int) ---
    len :: proc(L: ^State, idx: c.int) ---

    stringtonumber :: proc(L: ^State, s: cstring) -> c.size_t ---

    getallocf :: proc(L: ^State, ud: ^rawptr) -> Alloc ---
    setallocf :: proc(L: ^State, f: Alloc, ud: rawptr) ---

    toclose :: proc(L: ^State, idx: c.int) ---

    /*
    ** Debug functions
    */
    getstack :: proc(L: ^State, level: c.int, ar: ^Debug) -> c.int ---
    getinfo :: proc(L: ^State, what: cstring, ar: ^Debug) -> c.int ---
    getlocal :: proc(L: ^State, ar: ^Debug, n: c.int) -> cstring ---
    setlocal :: proc(L: ^State, ar: ^Debug, n: c.int) -> cstring ---
    getupvalue :: proc(L: ^State, funcindex: c.int, n: c.int) -> cstring ---
    setupvalue :: proc(L: ^State, funcindex: c.int, n: c.int) -> cstring ---

    upvalueid :: proc(L: ^State, fidx: c.int, n: c.int) -> rawptr ---
    upvaluejoin :: proc(L: ^State, fidx1: c.int, n1: c.int, fidx2: c.int, n2: c.int) ---

    sethook :: proc(L: ^State, func: Hook, mask: c.int, count: c.int) ---
    gethook :: proc(L: ^State) -> Hook ---
    gethookmask :: proc(L: ^State) -> c.int ---
    gethookcount :: proc(L: ^State) -> c.int ---

    setcstacklimit :: proc(L: ^State, limit: c.uint) -> c.int ---
}

/*
** Comparison and arithmetic op codes
*/
OPADD: c.int : 0	/* ORDER TM, ORDER OP */
OPSUB: c.int : 1
OPMUL: c.int : 2
OPMOD: c.int : 3
OPPOW: c.int : 4
OPDIV: c.int : 5
OPIDIV: c.int : 6
OPBAND: c.int : 7
OPBOR: c.int : 8
OPBXOR: c.int : 9
OPSHL: c.int : 10
OPSHR: c.int : 11
OPUNM: c.int : 12
OPBNOT: c.int : 13

OPEQ: c.int : 0
OPLT: c.int : 1
OPLE: c.int : 2

/*
** garbage-collection options
*/

GCSTOP: c.int : 0
GCRESTART: c.int : 1
GCCOLLECT: c.int : 2
GCCOUNT: c.int : 3
GCCOUNTB: c.int : 4
GCSTEP: c.int : 5
GCSETPAUSE: c.int : 6
GCSETSTEPMU: c.int : 7
GCISRUNNING: c.int : 9
GCGEN: c.int : 10
GCINC: c.int : 11

/*
** 'load' and 'call' macros (load and run Lua code)
*/
call :: #force_inline proc(L: ^State, n: c.int, r: c.int) { callk(L, (n), (r), 0, nil) }
pcall :: #force_inline proc(L: ^State, n: c.int, r: c.int, f: c.int) -> c.int { return pcallk(L, (n), (r), (f), 0, nil) }

/*
** coroutine macros
*/
lua_yield :: #force_inline proc(L: ^State, n: c.int) -> c.int { return yieldk(L, (n), 0, nil) }


/*
** lua macro conversions
*/

tonumber :: #force_inline proc(L: ^State, i: c.int) -> Number { return tonumberx(L,(i),nil) }
tointeger :: #force_inline proc(L: ^State, i: c.int) -> Integer { return tointegerx(L,(i),nil) }

pop :: #force_inline proc(L: ^State, n: c.int) { settop(L, -(n)-1) }

newtable :: #force_inline proc(L: ^State) { createtable(L, 0, 0) }

register :: #force_inline proc(L: ^State, n: cstring, f: CFunction) { pushcfunction(L, (f)); setglobal(L, (n)); }

pushcfunction :: #force_inline proc(L: ^State, f: CFunction) { pushcclosure(L, (f), 0) }


/*
** Lua type checks
*/
isfunction      :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TFUNCTION }

istable         :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TTABLE }

islightuserdata :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TLIGHTUSERDATA }

isboolean       :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TBOOLEAN }

isthread        :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TTHREAD }

isnil           :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TNIL }
isnone          :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) == TNONE } 
isnoneornil     :: #force_inline proc(L: ^State, n: c.int) -> bool    { return type(L, (n)) <= 0 }

pushliteral :: #force_inline proc(L: ^State, s: cstring) -> cstring { return pushstring(L, s) }

pushglobaltable :: #force_inline proc(L: ^State) -> c.int { return rawgeti(L, REGISTRYINDEX, RIDX_GLOBALS) }

tostring :: #force_inline proc(L: ^State, i: c.int) -> cstring { return tolstring(L, (i), nil) }

insert :: #force_inline proc(L: ^State, idx: c.int) { rotate(L, (idx), 1) }

remove :: #force_inline proc(L: ^State, idx: c.int) { rotate(L, (idx), -1); pop(L, 1) }

replace :: #force_inline proc(L: ^State, idx: c.int) { copy(L, -1, (idx)); pop(L, 1) }


/* Functions to be called by the debugger in specific events */
Hook :: proc(L: ^State, ar: ^Debug);



Debug :: struct {
  event: c.int,
  name: cstring, /* (n) */
  namewhat: cstring, /* (n) 'global', 'local', 'field', 'method' */
  what: cstring, /* (S) 'Lua', 'C', 'main', 'tail' */
  source: cstring, /* (S) */
  srclen: c.size_t, /* (S) */
  currentline: c.int, /* (l) */
  linedefined: c.int, /* (S) */
  lastlinedefined: c.int, /* (S) */
  nups: c.uchar, /* (u) number of upvalues */
  nparams: c.uchar, /* (u) number of parameters */
  isvararg: c.char, /* (u) */
  istailcall: c.char, /* (t) */
  ftransfer: c.ushort,   /* (r) index of first value transferred */
  ntransfer: c.ushort,   /* (r) number of transferred values */
  short_src: [IDSIZE]c.char, /* (S) */

  /* private part */
  i_ci: ^struct {},  /* active function */
};

/******************************************************************************
* Copyright (C) 1994-2020 Lua.org, PUC-Rio.
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
******************************************************************************/