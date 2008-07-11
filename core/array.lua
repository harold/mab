Roots.Array.new = createLuaFunc( function( context ) -- Array#new
	local args = context.callState.message.arguments
	local theArray = runtime.childFrom( Roots.Array )
	for i=1, #args do
		theArray[i] = evaluateExpression( context.callState.callingContext, context.callState.callingContext, args[i] )
	end
	return theArray
end )

Roots.Array.push = createLuaFunc( function( context ) -- Array#push
	local args = context.callState.message.arguments
	local theOldSize = #context.self
	for i=1, #args do
		local theExpressionValue = evaluateExpression( context.callState.callingContext, context.callState.callingContext, args[i] )
		context.self[ theOldSize + i ] = theExpressionValue
	end
end )

Roots.Array.at = createLuaFunc( 'index', function( context ) -- Array#at
	return context.self[ runtime.luanumber[context.index] ]
end)
Roots.Array.atPut = createLuaFunc( 'index', 'value', function( context ) -- Array#atPut
	-- TODO: HH - holycrap error checking
	context.self[ runtime.luanumber[context.index] ] = context.value
end)

Roots.Array.size = createLuaFunc( function( context ) -- Array#size
	return runtime.number[ #context.self ]
end)

Roots.Array.join = createLuaFunc( 'separator', function( context ) -- Array#join
	local theMessages = {}
	for i,message in ipairs(context.self) do
		theMessages[i] = toObjString( message )
	end
	local theSeparator = context.separator ~= Roots['nil'] and toLuaString( context.separator ) or runtime.luastring[ ' ' ]
	return runtime.string[ table.concat( theMessages, theSeparator ) ]
end )

-- TODO: holycrap these are brutal.
Roots.Array.each = createLuaFunc( function( context ) -- Array#each
	local args = context.callState.message.arguments
	for i,v in ipairs(context.self) do
	  -- What could possibly go wrong?
		context[ runtime.luastring[args[1][1][1].identifier] ] = v
		for i,v in ipairs(args[2]) do
			evaluateExpression( context, context, v )
		end
	end
end )

Roots.Array.eachWithIndex = createLuaFunc( function( context ) -- Array#eachWithIndex
	local args = context.callState.message.arguments
	for i,v in ipairs(context.self) do
	  -- What could possibly go wrong?
		context[ runtime.luastring[args[1][1][1].identifier] ] = v
	  -- What could possibly go wrong?
		context[ runtime.luastring[args[2][1][1].identifier] ] = runtime.number[i]
		for i,v in ipairs(args[3]) do
			evaluateExpression( context, context, v )
		end
	end
end )

Roots.Array.toString = createLuaFunc( function( context ) -- Array#toString
	local theString = "Array new("
	for i,v in ipairs(context.self) do
		theString = theString .. tostring(v) 
		if i ~= #context.self then
			theString = theString .. ", "
		end
	end
	theString = theString .. ")"
	return runtime.string[theString]
end )
