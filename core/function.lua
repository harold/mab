Roots.Function.call = createLuaFunc( function( context ) -- Function#call
	-- Hrm...who is the receiver of this?
	-- Seems like the message that retrieved this function value
	-- should remember the receiver of that message so that I can nab it.
end )

Roots.Function.toString = createLuaFunc( function( context ) -- Function#toString
	local theIntrinsicName = rawget( context.self, '__name' )
	if theIntrinsicName then
		return runtime.string[ string.format("%s (0x%04x)", runtime.luastring[theIntrinsicName], runtime.ObjectId[ context.self ] ) ]
	else
		local theArgNames = {}
		for i,argName in ipairs(context.self.namedArguments) do
			theArgNames[i] = runtime.luastring[argName]
		end
		return runtime.string[
			string.format( "<%s (%s) (0x%04x)>",
				runtime.luastring[ context.self.__name ],
				table.concat( theArgNames, ", " ),
				runtime.ObjectId[ context.self ]
			)
		]
	end
end )

