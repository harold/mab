-- runtime.blank()/runtime.childFrom() use runtime.string, and
-- runtime.string needs core.String to be defined to work properly,
-- so DON'T SUPPLY A NAME HERE.
Object = runtime.blank( )
String = runtime.childFrom( Object )

-- Convert String objects to/from Lua flavor
runtime.string    = {}
runtime.luastring = {}
setmetatable( runtime.string, {
	__index = function( self, string )
		local stringObject = runtime.childFrom( String )
		self[ string ] = stringObject
		runtime.luastring[ stringObject ] = string
		return stringObject
	end
} )

runtime.Meta.__tostring = function( object )
  -- return toLuaString( object ) or "--nil--"
  if runtime.luastring[object] then
    return "'"..runtime.luastring[object].."'"
  elseif object == String then
    return runtime.luastring[object.__name]
  else
  	return runtime.luastring[ sendMessage( object, messageCache['toString'] ) ]
  end
end

Object.__name = runtime.string["Object"]
String.__name = runtime.string["String"]

Array    = runtime.childFrom( Object, "Array" )
Chunk    = runtime.childFrom( Array, "Chunk" )
Function = runtime.childFrom( Chunk, "Function" )


Context  = runtime.childFrom( Object, "Context" ) -- aka "Locals"
Lawn     = runtime.childFrom( Context, "Lawn" )
