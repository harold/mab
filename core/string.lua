String['+'] = createLuaFunc( 'stringToAppend', function( context ) -- String#+
	return runtime.string[ runtime.luastring[context.self] .. toLuaString( context.stringToAppend ) ]
end )

String['*'] = createLuaFunc( 'reps', function( context ) -- String#*
	local string = runtime.luastring[ context.self ]
	local reps   = runtime.luanumber[ context.reps ]
	if not reps then
		local theNextMessageOrLiteral = context.message.next
		if theNextMessageOrLiteral == Lawn['nil'] then
			error( "String#* is missing a repetition count" )
		end
		context.owningContext.nextMessage = theNextMessageOrLiteral.next
		rvalue = runtime.luanumber[ sendMessage( context.owningContext, theNextMessageOrLiteral ) ]
	end
	return runtime.string[ string.rep( string, reps ) ]
end )

String.asCode = createLuaFunc( function( context ) -- String#asCode
	return runtime.string[ string.format( "%q", runtime.luastring[context.self] ) ]
end )