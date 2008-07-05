require 'runtime'
module( 'core', package.seeall )

function createChunk( ... )
	local chunk = runtime.childFrom( Roots.Chunk )
	if select('#',...) > 0 then
		addChildren( chunk, ... )
	end
	return chunk
end

function createExpression( ... )
	local expression = runtime.childFrom( Roots.Expression )
	if select('#',...) > 0 then
		addChildren( expression, ... )
	end
	return expression
end

function createMessage( messageString, ... )
	local message = runtime.childFrom( Roots.Message )
	message.identifier = runtime.string[messageString]
	message.arguments = runtime.childFrom( Roots.ArgList )
	if select('#',...) > 0 then
		addChildren( message.arguments, ... )
	end
	return message
end

function addChildren( parent, ... )
	for i=1,select('#',...) do
		local child = select(i,...)
		local index = #parent + 1
		parent[index] = child
		child.parent  = parent
		if index > 1 then
			parent[index-1].next = child
			child.previous       = parent[index-1]
		end
	end
	return parent
end

function createLuaFunc( ... )
	local func = runtime.childFrom( Roots.Function )
	
	-- FIXME: sendMessageAsString( Roots.Array, 'new' ) fails; perhaps too soon?
	func.namedArguments = runtime.childFrom( Roots.Array )

	local theNumArgs = select('#',...) - 1
	for i=1,theNumArgs do
		local theArgName = select(i,...)
		if type(theArgName)~="string" then
			-- TODO: remove for speed
			error( "Argument #"..i.." to createLuaFunc() is "..tostring(theArgName))
		end
		func.namedArguments[i] = runtime.string[theArgName]
	end
	
	local theFunction = select(theNumArgs+1,...)
	if type(theFunction)~="function" then
		-- TODO: remove for speed
		error( "Final argument to createLuaFunc() is not a function (it is a "..tostring(theFunction)..")" )
	end
		
	func.__luaFunction = theFunction
	return func
end

-- ##########################################################################

function evaluateChunk( chunk, context )
	if not context then context = Roots.Lawn end
	if chunk.__luaFunction ~= Roots['nil'] then
		return chunk.__luaFunction( context ) or Roots['nil']
	else
		local lastValue = Roots['nil']
		for _,expression in ipairs(chunk) do
			lastValue = evaluateExpression( expression, context )
		end
		return lastValue
	end
end

function evaluateExpression( expression, context )
	--TODO: via setSlot as a message?
	expression.context = context
	if expression.creationContext == Roots['nil'] then
		expression.creationContext = context
	end

	local receiver = context
	context.nextMessage = expression[1]
	while context.nextMessage ~= Roots['nil'] do
		local theCurrentMessage = context.nextMessage
		context.nextMessage = context.nextMessage.next
		receiver = sendMessage( receiver, theCurrentMessage )
	end
		
	return receiver
end

function sendMessage( receiver, messageOrLiteral )
	if messageOrLiteral.identifier == Roots['nil'] then
		-- Presumably this is a literal
		-- TODO: Warning about literals sent as message if the receiver isn't a context
		return messageOrLiteral
	end

	local messageName = runtime.luastring[ messageOrLiteral.identifier ]
	local obj = receiver[ messageName ]

	if obj == Roots['nil'] and messageName ~= 'nil' then
		-- TODO: method_mising
		-- FIXME: No need to error, just flow through to return Roots.nil
		if arg.debugLevel and arg.debugLevel >= 1 then
			print( "Warning: Cannot find message '"..tostring(messageName).."' on "..tostring(receiver) )
		end
	elseif obj.executeOnAccess ~= Roots['nil'] then
		obj = executeFunction( obj, receiver, messageOrLiteral )
	end

	return obj or Roots['nil']
end

function executeFunction( functionObject, receiver, message )
	local callingContext = message.parent.context
	if callingContext == Roots['nil'] then
		-- if _DEBUG then print( "Warning: No message/expression context when sending '"..runtime.luastring[message.identifier].."'...so I'm using the Lawn instead.") end
		callingContext = Roots.Lawn
	end
	
	local context = runtime.childFrom( callingContext )
	context.self = receiver
	context.callState = runtime.childFrom( Roots.CallState )
	context.callState.target  = receiver
	context.callState.message = message
	context.callState.context = context
	context.callState['function'] = functionObject
	context.callState.callingContext = callingContext
	
	-- Setup local parameters
	-- TODO: syntax to allow eval of chunks to be optional
	if functionObject.namedArguments ~= Roots['nil'] then
		local theNextMessageInCallingContext = callingContext.nextMessage
		for i=1,#functionObject.namedArguments do
			-- TODO: warn if this conflicts, or maybe don't shove locals onto the context, but inherit the context from locals
			local theArgName = runtime.luastring[ functionObject.namedArguments[i] ]
			if message.arguments[i] ~= Roots['nil'] then
				context[ theArgName ] = evaluateChunk( message.arguments[i], callingContext )
			else
				if _DEBUG then print( "Warning: No argument passed for parameter '"..theArgName.."'; setting to Roots.nil" ) end
				context[ theArgName ] = Roots['nil']
			end
		end
		callingContext.nextMessage = theNextMessageInCallingContext
	end

	return evaluateChunk( functionObject, context )
end

-- ##########################################################################

-- Cache for simple no-argument messages sent from Lua, indexed by message identifier
messageCache = {}
setmetatable( messageCache, {
	__index = function( t, messageString )
		local theMessage = createMessage( messageString )
		t[ messageString ] = theMessage
		return theMessage
	end
} )

function sendMessageAsString( object, messageString, ... )
	local theMessage
	if select('#',...) == 0 then
		theMessage = messageCache[messageString]
	else
		-- Assume each argument to the message is a simple Mab object;
		-- wrap in chunks for proper passing
		local theArgChunks = { }
		theMessage = createMessage( messageString, ... )
	end
	-- TODO: lookup via getSlot or sendMessage? (would allow warnings or errors to be single sourced)
	local theFunction = object[messageString]
	if theFunction == Roots['nil'] then
		error( "Cannot find '"..messageString.."' on "..tostring(object) )
	end
	return executeFunction( theFunction, object, theMessage )
end

-- ##########################################################################

function toObjString( object )
	if object == String then
		object = object.__name
	elseif not runtime.isKindOf( object, String ) then
		-- TODO: Perhaps replace test with a simple runtime.luastring[object], since every string object should have an entry here
		object = sendMessage( object, messageCache['toString'] )
	end
	-- TODO: Perhaps replace test with a simple runtime.luastring[object], since every string object should have an entry here
	if runtime.isKindOf( object, String ) then
		return object
	else
		error( "toString returned something other than a String object ("..type(object)..")" )
	end
end

function toLuaString( object )
	return runtime.luastring[ toObjString(object) ]
end

-- ##########################################################################

-- TODO: replace with uber-portable directory scan
lua_files = {
	"1a_basics.lua",
	"arglist.lua",
	"array.lua",
	"boolean.lua",
	"callstate.lua",
	"chunk.lua",
	"context.lua",
	"expression.lua",
	"function.lua",
	"lawn.lua",
	"message.lua",
	"number.lua",
	"object.lua",
	"ornaments.lua",
	"roots.lua",
	"string.lua",
	"zz_finish.lua"
}

for _,fileName in ipairs(lua_files) do
	local fileChunk = loadfile( "core/" .. fileName )
	setfenv( fileChunk, _M )
	fileChunk( )
end