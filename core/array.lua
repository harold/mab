Array.push = createLuaFunc( function( context ) -- Array#push
  local args = context.message.arguments
  local theOldSize = #context.self
  for i=1, #args do
  	local theExpressionValue = evaluateChunk( args[i], context.owningContext )
    context.self[ theOldSize + i ] = theExpressionValue
  end
end )

Array.size = createLuaFunc( function( context ) -- Array#size
  return runtime.number[ #context.self ]
end)

Array.join = createLuaFunc( 'separator', function( context ) -- Array#join
  local theMessages = {}
  for i,message in ipairs(context.self) do
    theMessages[i] = toObjString( message )
  end
  local theSeparator = context.separator and toLuaString( context.separator ) or runtime.luastring[ ' ' ]
  return runtime.string[ table.concat( theMessages, theSeparator ) ]
end )

Array.each = createLuaFunc( function( context ) -- Array#each
  -- TODO: implement this properly
  for i,v in ipairs(context.self) do
    print(i,v)
  end
end )
