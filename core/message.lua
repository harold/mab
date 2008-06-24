Message = runtime.childFrom( Object, "Message" )

Message.new = createLuaFunc( "identifier", function( context ) -- Message#new
  -- TODO: perhaps stop trying to be so DRY and just runtime.childFrom( Message )
  local theMessage = executeFunction( Object.new, context.self, messageCache['new'] )
  if context.identifier ~= Lawn['nil'] then
    theMessage.identifier = context.identifier
  end

  theMessage.arguments = sendMessageAsString( ArgList, 'new' )
  -- Hard-set values to allow currying
  -- TODO: perhaps allow storing as chunks in the future?
	local args = context.message.arguments
	for i=2, #args do
		theMessage.arguments[i-1] = createChunk( createExpression( evaluateChunk( args[i], context.owningContext ) ) )
	end
	
  return theMessage
end )

Message.addArgument = createLuaFunc( "inArgValue", function( context ) -- Message#addArgument
  local args = context.self.arguments
  args[ #args + 1 ] = createChunk( createExpression( context.inArgValue ) )
  return runtime.number[ #args ]
end )

Message.asCode = createLuaFunc( function( context ) -- Message#asCode
  local theResult  
  local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		theResult = theIntrinsicName
  elseif #context.self.arguments == 0 then
    theResult = context.self.identifier
  else
    local theArgumentsCode = {}
    for i,argumentChunk in ipairs(context.self.arguments ) do
      theArgumentsCode[i] = runtime.luastring[ sendMessageAsString( argumentChunk, 'asCode' ) ]
    end
    theResult = runtime.string[ string.format( "%s( %s )",
      runtime.luastring[ context.self.identifier ],
      table.concat( theArgumentsCode, ", " )
    ) ]
  end
  return theResult
end )

Message.toString = createLuaFunc( function( context ) -- Message#toString
  local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return runtime.string[ string.format("%s (0x%04x)", runtime.luastring[theIntrinsicName], runtime.ObjectId[ context.self ] ) ]
  else
    local theNumberOfArguments = context.self.arguments and #context.self.arguments or -1
    return runtime.string[
      string.format( "<%s '%s' %d arg%s (0x%04x)>",
        runtime.luastring[ context.self.__name ],
        runtime.luastring[ context.self.identifier ],
        theNumberOfArguments,
        theNumberOfArguments == 1 and "" or "s",
        runtime.ObjectId[ context.self ]
      )
    ]
  end
end )
