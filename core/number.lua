Number = runtime.childFrom( Object, "Number" )

runtime.number		= {}
runtime.luanumber = {}
setmetatable( runtime.number, {
	__index = function( self, value )
		local numberObject = runtime.childFrom( Number )
		self[ value ] = numberObject
		runtime.luanumber[ numberObject ] = value
		return numberObject
	end
} )

Number['+'] = createLuaFunc( 'addend', function( context ) -- Number#+
	local lvalue = runtime.luanumber[ context.self ]
	local rvalue = runtime.luanumber[ context.addend ]
	if not rvalue then
		local theNextMessageOrLiteral = context.message.next
		if theNextMessageOrLiteral == Lawn['nil'] then
			error( "Number#+ is missing an addend" )
		end
		context.owningContext.nextMessage = theNextMessageOrLiteral.next
		rvalue = runtime.luanumber[ sendMessage( context.owningContext, theNextMessageOrLiteral ) ]
	end
	return runtime.number[ lvalue + rvalue ]
end )

Number['-'] = createLuaFunc( 'subtrahend', function( context ) -- Number#-
	local lvalue = runtime.luanumber[ context.self ]
	local rvalue = runtime.luanumber[ context.subtrahend ]
	if not rvalue then
		local theNextMessageOrLiteral = context.message.next
		if theNextMessageOrLiteral == Lawn['nil'] then
			error( "Number#- is missing a subtrahend" )
		end
		context.owningContext.nextMessage = theNextMessageOrLiteral.next
		rvalue = runtime.luanumber[ sendMessage( context.owningContext, theNextMessageOrLiteral ) ]
	end
	return runtime.number[ lvalue - rvalue ]
end )

Number['>'] = createLuaFunc( 'rvalue', function( context ) -- Number#>
	local lvalue = runtime.luanumber[ context.self ]
	local rvalue = runtime.luanumber[ context.rvalue ]
	return (lvalue > rvalue) and Lawn['true'] or Lawn['false']
end )

Number['<'] = createLuaFunc( 'rvalue', function( context ) -- Number#<
	local lvalue = runtime.luanumber[ context.self ]
	local rvalue = runtime.luanumber[ context.rvalue ]
	return (lvalue < rvalue) and Lawn['true'] or Lawn['false']
end )

Number['*'] = createLuaFunc( 'multiplicand', function( context ) -- Number#*
	local lvalue = runtime.luanumber[ context.self ]
	local rvalue = runtime.luanumber[ context.multiplicand ]
	if not rvalue then
		local theNextMessageOrLiteral = context.message.next
		if theNextMessageOrLiteral == Lawn['nil'] then
			error( "Number#* is missing a multiplicand" )
		end
		context.owningContext.nextMessage = theNextMessageOrLiteral.next
		rvalue = runtime.luanumber[ sendMessage( context.owningContext, theNextMessageOrLiteral ) ]
	end
	return runtime.number[ lvalue * rvalue ]
end )

Number['/'] = createLuaFunc( 'divisor', function( context ) -- Number#/
	local lvalue = runtime.luanumber[ context.self ]
	local rvalue = runtime.luanumber[ context.divisor ]
	if not rvalue then
		local theNextMessageOrLiteral = context.message.next
		if theNextMessageOrLiteral == Lawn['nil'] then
			error( "Number#/ is missing a divisor" )
		end
		context.owningContext.nextMessage = theNextMessageOrLiteral.next
		rvalue = runtime.luanumber[ sendMessage( context.owningContext, theNextMessageOrLiteral ) ]
	end
	return runtime.number[ lvalue / rvalue ]
end )

Number.abs = createLuaFunc( function( context ) -- Number#abs
	local myValue = runtime.luanumber[ context.self ]
	return runtime.number[ math.abs( myValue ) ]
end )

Number['sin'] = createLuaFunc( function( context ) -- Number#sin
	local myValue = runtime.luanumber[ context.self ]
	return runtime.number[ math.sin(math.rad( myValue )) ]
end )

Number['cos'] = createLuaFunc( function( context ) -- Number#cos
	local myValue = runtime.luanumber[ context.self ]
	return runtime.number[ math.cos(math.rad( myValue )) ]
end )

Number.toString = createLuaFunc( function( context ) -- Number#toString
	local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return runtime.string[ string.format("%s (0x%04x)", runtime.luastring[theIntrinsicName], runtime.ObjectId[ context.self ] ) ]
	else
		return runtime.string[ tostring( runtime.luanumber[ context.self ] ) ]
	end
end )

Number.asCode = Number.toString

