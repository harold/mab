String['+'] = createLuaFunc( 'stringToAppend', function( context ) -- String#+
  return runtime.string[ runtime.luastring[context.self] .. toLuaString( context.stringToAppend ) ]
end )

String.asCode = createLuaFunc( function( context ) -- String#asCode
  return runtime.string[ string.format( "%q", runtime.luastring[context.self] ) ]
end )