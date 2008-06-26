Chunk.eval = createLuaFunc( function( context ) -- Chunk#eval
	-- Users may optionally specify an explicit context to evaluate in
	local evalContext = context.evalContext

	-- Chunks explicitly created (Chunk new) have a creationContext
	if evalContext == Lawn['nil'] then
		evalContext = context.self.creationContext
		if _DEBUG then print( "No explicit context for Chunk#eval; using "..tostring(evalContext) ) end
		-- As a fallback, evaluate the expression in the context eval was called in
		if evalContext == Lawn['nil'] then
			evalContext = context.owningContext
			if _DEBUG then print( "...and no creationContext, either; using "..tostring(evalContext) ) end
		end
	end

	return evaluateChunk( context.self, evalContext )
end )

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

