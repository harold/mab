Roots.String['+'] = createLuaFunc( 'stringToAppend', function( context ) -- String#+
	return runtime.string[ runtime.luastring[context.self] .. toLuaString( context.stringToAppend ) ]
end )

Roots.String['*'] = createLuaFunc( 'reps', function( context ) -- String#*
	local string = runtime.luastring[ context.self ]
	local reps   = runtime.luanumber[ context.reps ]
	if not reps then
		local theNextMessageOrLiteral = context.callState.message.next
		if theNextMessageOrLiteral == Roots['nil'] then
			error( "String#* is missing a repetition count" )
		end
		context.callState.callingContext.nextMessage = theNextMessageOrLiteral.next
		rvalue = runtime.luanumber[ sendMessage( context.callState.callingContext, theNextMessageOrLiteral, context.callState.callingContext ) ]
	end
	return runtime.string[ string.rep( string, reps ) ]
end )

Roots.String.asCode = createLuaFunc( function( context ) -- String#asCode
	return runtime.string[ string.format( "%q", runtime.luastring[context.self] ) ]
end )