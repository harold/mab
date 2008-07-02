module( 'args', package.seeall )

function processArguments( options )
	local unnamed  = options.unnamed  or {}
	local named    = options.named    or {}
	local flags    = options.flags    or {}
	local numbers  = options.numbers  or {}
	local required = options.required or {}

	for _,name in ipairs(named) do
		named[ "-"..string.sub(name,1,1) ] = name
		named[ "--"..name ] = name
	end

	-- Convert array to hash for convenience
	for _,v in ipairs(flags) do flags[v] = true end
	
	-- Modify the global arg table to have named values
	local nextArgName = unnamed[1]
	for i,thisArg in ipairs(arg) do
		local argName = named[ thisArg ]
		if argName then
			if flags[argName] then
				arg[argName] = true
			else
				nextArgName = argName
			end
		else
			if nextArgName then
				arg[nextArgName] = thisArg
				if nextArgName == unnamed[1] then
					table.remove( unnamed, 1 )
				end
			end
			nextArgName = unnamed[1]
		end
	end
	
	-- Convert numeric values
	for _,argName in ipairs(numbers) do
		if arg[ argName ] then
			local value = tonumber( arg[argName] )
			if value then
				arg[ argName ] = value
			else
				print( "Error: '"..argName.."' must be a number. ('"..arg[argName].."' is not a number)" )
			end
		end
	end
	
	for _,argName in ipairs(required) do
		if not arg[argName] then
			return false
		end
	end
	
	return true
end
