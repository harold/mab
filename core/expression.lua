Roots.Expression = runtime.childFrom( Roots.Array, "Expression" )

Roots.Expression.new = createLuaFunc( function( context ) -- Expression#new
	-- Re-use existing expression created for the first chunk argument, if available
	local args = context.callState.message.arguments
	local theExpression = args[1] ~= Roots['nil'] and args[1][1] or executeFunction( Roots.Object.new, context.self, messageCache['new'] )
	theExpression.creationContext = context.callState.callingContext
	return theExpression
end )

Roots.Expression.appendMessage = Roots.Array.push

Roots.Expression.eval = createLuaFunc( 'evalContext', function( context ) -- Expression#eval
	-- Users may optionally specify an explicit context to evaluate in
	local evalContext = context.evalContext
	
	-- Expressions explicitly created (Expression new) have a creationContext
	if evalContext == Roots['nil'] then
		evalContext = context.self.creationContext
		if _DEBUG then print( "No explicit context for Expression#eval; using "..tostring(evalContext) ) end
		-- As a fallback, evaluate the expression in the context eval was called in
		if evalContext == Roots['nil'] then
			evalContext = context.callState.callingContext
			if _DEBUG then print( "...and no creationContext, either; using "..tostring(evalContext) ) end
		end
	end
	
	return evaluateExpression( context.self, evalContext )
end )

Roots.Expression.asCode = createLuaFunc( function( context ) -- Expression#asCode
	local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return theIntrinsicName
	else
		local theMessagesCode = {}
		for i,message in ipairs(context.self) do
			theMessagesCode[i] = runtime.luastring[ sendMessageAsString( message, 'asCode' ) ]
		end
		return runtime.string[ table.concat( theMessagesCode, " " ) ]
	end
end )

Roots.Expression.toString = createLuaFunc( function( context ) -- Expression#toString
	local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return runtime.string[ string.format("%s (0x%04x)", runtime.luastring[theIntrinsicName], runtime.ObjectId[context.self] ) ]
	else		
		local theMessagesCode = {}
		for i,message in ipairs(context.self) do
			theMessagesCode[i] = runtime.luastring[ sendMessageAsString( message, 'asCode' ) ]
		end
		return runtime.string[
			string.format( "<%s : %s : (0x%04x)>",
				runtime.luastring[context.self.__name],
				table.concat( theMessagesCode, " " ),
				runtime.ObjectId[context.self]
			)
		]
	end
end )

