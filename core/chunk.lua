Chunk.asCode = createLuaFunc( function( context ) -- Chunk#asCode
	local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return theIntrinsicName
	else
		local theExpressionsCode = {}
		for i,expression in ipairs(context.self) do
			theExpressionsCode[i] = runtime.luastring[ sendMessageAsString( expression, 'asCode' ) ]
		end
		return runtime.string[ table.concat( theExpressionsCode, "\n" ) ]
	end
end )

Chunk.toString = createLuaFunc( function( context ) -- Chunk#toString
	local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return runtime.string[ string.format("%s (0x%04x)", runtime.luastring[theIntrinsicName], runtime.ObjectId[context.self] ) ]
	else
		local theExpressionsCode = {}
		for i,expression in ipairs(context.self) do
			theExpressionsCode[i] = "\t" .. runtime.luastring[ sendMessageAsString( expression, 'asCode' ) ]
		end
		return runtime.string[ string.format( "<%s (0x%04x)\n%s\n>",
			runtime.luastring[ context.self.__name ],
			runtime.ObjectId[context.self],
			table.concat( theExpressionsCode, "\n" )
		) ]
	end
end )

