package lua
import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:strings"

/*
@@ IS32INT is true if 'int' has (at least) 32 bits.
*/
IS32INT :: size_of(c.int) >= 3

INT_INT :: 1
INT_LONG :: 2
INT_LONGLONG :: 3

FLOAT_FLOAT :: 1
FLOAT_DOUBLE :: 2
FLOAT_LONGDOUBLE :: 3

/*
** default configuration for 64-bit Lua ('long long' and 'double')
*/
INT_TYPE :: INT_LONGLONG
FLOAT_TYPE :: FLOAT_DOUBLE

/*
** {==================================================================
** Configuration for Paths.
** ===================================================================
*/

/*
** PATH_SEP is the character that separates templates in a path.
** PATH_MARK is the string that marks the substitution points in a
** template.
** EXEC_DIR in a Windows path is replaced by the executable's
** directory.
*/
PATH_SEP:  cstring : ":"
PATH_MARK: cstring : "?"
EXEC_DIR:  cstring : "!"

VDIR: cstring :	VERSION_MAJOR + "." + VERSION_MINOR

when ODIN_OS == "windows" {
/*
** In Windows, any exclamation mark ('!') in the path is replaced by the
** path of the directory of the executable file of the current process.
*/
LDIR: cstring : "!\\lua\\"
CDIR: cstring : "!\\"
SHRDIR: cstring : "!\\..\\share\\lua\\" + VDIR + "\\"

PATH_DEFAULT: cstring :                                         \
		LDIR + "?.lua;" +  LDIR + "?\\init.lua;" +              \
		CDIR + "?.lua;" +  CDIR + "?\\init.lua;" +              \
		SHRDIR + "?.lua;" + SHRDIR + "?\\init.lua;" +           \
		".\\?.lua;" + ".\\?\\init.lua"

CPATH_DEFAULT: cstring :                                        \
		CDIR + "?.dll;" +                                       \
		CDIR + "..\\lib\\lua\\" + VDIR + "\\?.dll;" +           \
		CDIR + "loadall.dll;" + ".\\?.dll;" +                   \
		CDIR + "?54.dll;" + ".\\?54.dll"
} else {

ROOT: cstring : "/usr/local/"
LDIR: cstring : ROOT + "share/lua/" + VDIR +  "/"
CDIR: cstring : ROOT + "lib/lua/" + VDIR + "/"

PATH_DEFAULT: cstring :                                         \
		LDIR + "?.lua;" + LDIR + "?/init.lua;" +                \
		CDIR + "?.lua;" + CDIR + "?/init.lua;" +                \
		"./?.lua;" + "./?/init.lua"

CPATH_DEFAULT: cstring :                                        \
		CDIR + "?.so;" + CDIR + "loadall.so;" + "./?.so;" +     \
		CDIR + "lib?54.so;" + "./lib?54.so"
}

/*
@@ LUA_DIRSEP is the directory separator (for submodules).
** CHANGE it if your machine does not use "/" as the directory separator
** and is not Windows. (On Windows Lua automatically uses "\".)
*/
when ODIN_OS == "windows" do DIRSEP: cstring : "\\"
else do DIRSEP: cstring : "/"

number2str :: #force_inline proc(n: Number) -> cstring { return strings.clone_to_cstring(fmt.tprint(n)) }
integer2str :: #force_inline proc(n: Integer) -> cstring { return strings.clone_to_cstring(fmt.tprint(n)) }
numbertointeger :: #force_inline proc(n: Number) -> Integer { return cast(Integer)n }
str2number :: #force_inline proc(s: cstring) -> c.double { return libc.strtod(s, nil) }


//NUMBER :: c.double
//UACNUMBER :: c.double

//NUMBER_FRMLEN: cstring : ""
//NUMBER_FMT: cstring : "%.14g"

MAXSTACK :: 1000000

/*
@@ LUA_IDSIZE gives the maximum size for the description of the source
@@ of a function in debug information.
** CHANGE it if you want a different size.
*/
IDSIZE :: 60

/*
@@ LUAL_BUFFERSIZE is the buffer size used by the lauxlib buffer system.
*/
L_BUFFERSIZE :: ((c.int)(16 * size_of(rawptr) * size_of(Number)))