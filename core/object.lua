Object.new = createLuaFunc( function( context ) -- Object#new
	return runtime.childFrom( context.self )
end )

Object.setSlot = createLuaFunc( 'slotName', 'slotValue', function( context ) -- Object#setSlot
	-- TODO: get via messages?
	-- TODO: what about non-string slots? And should string objects be indexed by that table or the string?
	context.self[ toLuaString( context.slotName ) ] = context.slotValue
	return context.slotValue
end )

Object.getSlot = createLuaFunc( 'slotName', function( context ) -- Object#getSlot
	-- TODO: get via messages?
	-- TODO: should I really be casting to a string always? 
	local slotName = toLuaString( context.slotName )
	return context.self[ slotName ] or Lawn['nil']
end )

Object.id = createLuaFunc( function( context ) -- Object#id
	return runtime.number[ runtime.ObjectId[ context.self ] ]
end )

Object.self = createLuaFunc( function( context ) -- Object#self
	return context.self
end )

Object['=='] = createLuaFunc( 'obj2', function( context ) -- Object#==
	return ( context.self == context.obj2 ) and Lawn['true'] or Lawn['false']
end )

Object.toString = createLuaFunc( function( context ) -- Object#toString
	local theIntrinsicName = rawget(context.self, "__name")
	if theIntrinsicName then
		return theIntrinsicName
	else
		return runtime.string[ string.format( "<%s instance>", runtime.luastring[ context.self.__name ] ) ]
	end
end )

Object.asCode = createLuaFunc( function( context ) -- Object#asCode
	local theIntrinsicName = rawget(context.self, "__name")
	if theIntrinsicName then
		return runtime.string[ string.format("%s (0x%04x)", runtime.luastring[theIntrinsicName], runtime.ObjectId[ context.self ] ) ]
	else
		return runtime.string[ string.format( "<%s instance (0x%04x)>", runtime.luastring[ context.self.__name ], runtime.ObjectId[ context.self ] ) ]
	end
end )

