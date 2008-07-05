Roots.Context.p = createLuaFunc( function( context ) -- Context#p
	local args = context.callState.message.arguments
	for i=1, #args do
		local theExpressionValue = evaluateChunk( args[i], context.callState.callingContext )
		print( toLuaString(theExpressionValue) )
	end
	return Roots['nil']
end )

Roots.Context.method = createLuaFunc( function( context ) -- Context#method
	local theLastChunk = context.callState.message.arguments[ #context.callState.message.arguments ]
	local theFunc = runtime.setInheritance( theLastChunk, Roots.Function )

	theFunc.namedArguments = sendMessageAsString( Roots.Array, 'new' )
	local theNumArgs = #context.callState.message.arguments-1
	for i=1,theNumArgs do
		theFunc.namedArguments[i] = context.callState.message.arguments[i][1][1].identifier
	end

	return theFunc
end )

Roots.Context['while'] = createLuaFunc( function( context ) -- Context#while
	if #context.callState.message.arguments ~= 2 then
		error( "while requires 2 arguments" )
	end
	local conditionChunk = context.callState.message.arguments[ 1 ]
	local clauseChunk    = context.callState.message.arguments[ 2 ]
	local contextOfWhile = context.self
	local condition = evaluateChunk( conditionChunk, contextOfWhile )
	local theReturnValue = Roots['nil']
	while condition ~= Roots['nil'] and condition ~= Roots['false'] do
		theReturnValue = evaluateChunk( clauseChunk, contextOfWhile )
		condition = evaluateChunk( conditionChunk, contextOfWhile )
	end
	return theReturnValue 
end )

Roots.Context['if'] = createLuaFunc( function( context ) -- Context#if
	local contextOfFunc	 = context.self
	local conditionValue = evaluateChunk( context.callState.message.arguments[ 1 ], contextOfFunc )
	if conditionValue ~= Roots['nil'] and conditionValue ~= Roots['false'] then
		return evaluateChunk( context.callState.message.arguments[ 2 ], contextOfFunc )
	else
		return evaluateChunk( context.callState.message.arguments[ 3 ], contextOfFunc )
	end
end )

Roots.Context.toString = createLuaFunc( function( context ) -- Context#toString
	if context.self == Roots.Lawn or context.self == Roots.Context then
		return context.self.__name
	else
		return runtime.string[
			string.format( "<Context of '%s'>",
				runtime.luastring[ context.self.callState.message.identifier ]
			)
		]
	end
end )

Roots.Context.asCode = createLuaFunc( function( context ) -- Context#asCode
	if context.self == Roots.Lawn then
		return runtime.string[ string.format("%s (0x%04x)", "Lawn", runtime.ObjectId[ context.self ] ) ]
	elseif context.self == Roots.Context then
		return runtime.string[ string.format("%s (0x%04x)", "Context", runtime.ObjectId[ context.self ] ) ]
	else
		return runtime.string[
			string.format( "<Context of '%s' (0x%04x)>",
				runtime.luastring[ context.self.callState.message.identifier ],
				runtime.ObjectId[ context.self ]
			)
		]
	end
end )

