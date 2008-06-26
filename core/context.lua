Context.p = createLuaFunc( function( context ) -- Context#p
	local args = context.message.arguments
	for i=1, #args do
		local theExpressionValue = evaluateChunk( args[i], context.owningContext )
		print( toLuaString(theExpressionValue) )
	end
	return Lawn['nil']
end )

Context.method = createLuaFunc( function( context ) -- Context#method
	local theLastChunk = context.message.arguments[#context.message.arguments]
	local theFunc = runtime.setInheritance( theLastChunk, Function )

	theFunc.namedArguments = sendMessageAsString( Array, 'new' )
	local theNumArgs = #context.message.arguments-1
	for i=1,theNumArgs do
		theFunc.namedArguments[i] = context.message.arguments[i][1][1].identifier
	end

	return theFunc
end )

Context['while'] = createLuaFunc( function( context ) -- Context#while
	local conditionChunk = context.message.arguments[ 1 ]
	local clauseChunk		 = context.message.arguments[ 2 ]
	local contextOfWhile = context.self
	local condition = evaluateChunk( conditionChunk, contextOfWhile )
	local theReturnValue = Lawn['nil']
	while condition ~= Lawn['nil'] and condition ~= Lawn['false'] do
		theReturnValue = evaluateChunk( clauseChunk, contextOfWhile )
		condition = evaluateChunk( conditionChunk, contextOfWhile )
	end
	return theReturnValue 
end )

Context['if'] = createLuaFunc( function( context ) -- Context#if
	local contextOfFunc	 = context.self
	local conditionValue = evaluateChunk( context.message.arguments[ 1 ], contextOfFunc )
	if conditionValue ~= Lawn['nil'] and conditionValue ~= Lawn['false'] then
		return evaluateChunk( context.message.arguments[ 2 ], contextOfFunc )
	else
		return evaluateChunk( context.message.arguments[ 3 ], contextOfFunc )
	end
end )

Context.toString = createLuaFunc( function( context ) -- Context#toString
	if context.self == Lawn or context.self == Context then
		return context.self.__name
	else
		return runtime.string[
			string.format( "<Context of '%s'>",
				runtime.luastring[ context.self.message.identifier ]
			)
		]
	end
end )

Context.asCode = createLuaFunc( function( context ) -- Context#asCode
	if context.self == Lawn then
		return runtime.string[ string.format("%s (0x%04x)", "Lawn", runtime.ObjectId[ context.self ] ) ]
	elseif context.self == Context then
		return runtime.string[ string.format("%s (0x%04x)", "Context", runtime.ObjectId[ context.self ] ) ]
	else
		return runtime.string[
			string.format( "<Context of '%s' (0x%04x)>",
				runtime.luastring[ context.self.message.identifier ],
				runtime.ObjectId[ context.self ]
			)
		]
	end
end )

