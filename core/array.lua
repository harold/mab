Array.new = createLuaFunc( function( context) -- Array#new
	local args = context.message.arguments
	local theArray = runtime.childFrom( Array )
	for i=1, #args do
		theArray[i] = evaluateChunk( args[i], context.owningContext )
	end
	return theArray
end )

Array.push = createLuaFunc( function( context ) -- Array#push
	local args = context.message.arguments
	local theOldSize = #context.self
	for i=1, #args do
		local theExpressionValue = evaluateChunk( args[i], context.owningContext )
		context.self[ theOldSize + i ] = theExpressionValue
	end
end )

Array.at = createLuaFunc( 'index', function( context ) --Array#at
	return context.self[ runtime.luanumber[context.index] ]
end)
Array.atPut = createLuaFunc( 'index', 'value', function( context ) -- Array#atPut
	-- TODO: HH - holycrap error checking
	context.self[ runtime.luanumber[context.index] ] = context.value
end)

Array.size = createLuaFunc( function( context ) -- Array#size
	return runtime.number[ #context.self ]
end)

Array.join = createLuaFunc( 'separator', function( context ) -- Array#join
	local theMessages = {}
	for i,message in ipairs(context.self) do
		theMessages[i] = toObjString( message )
	end
	local theSeparator = context.separator ~= Lawn['nil'] and toLuaString( context.separator ) or runtime.luastring[ ' ' ]
	return runtime.string[ table.concat( theMessages, theSeparator ) ]
end )

-- TODO: holycrap these are brutal.
Array.each = createLuaFunc( function( context ) -- Array#each
	local args = context.message.arguments
	for i,v in ipairs(context.self) do
	  -- What could possibly go wrong?
		context[ runtime.luastring[args[1][1][1].identifier] ] = v
		for i,v in ipairs(args[2]) do
			evaluateExpression( v, context )
		end
	end
end )

Array.eachWithIndex = createLuaFunc( function( context ) -- Array#eachWithIndex
	local args = context.message.arguments
	for i,v in ipairs(context.self) do
	  -- What could possibly go wrong?
		context[ runtime.luastring[args[1][1][1].identifier] ] = v
	  -- What could possibly go wrong?
		context[ runtime.luastring[args[2][1][1].identifier] ] = runtime.number[i]
		for i,v in ipairs(args[3]) do
			evaluateExpression( v, context )
		end
	end
end )

Array.toString = createLuaFunc( function( context ) -- Array#toString
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
