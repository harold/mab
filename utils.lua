function table.dump( t, indentLevel )
	if not indentLevel then indentLevel = 0 end
	local indent = ("  "):rep( indentLevel )
	print( "{ --" ..tostring(t) )
	for k,v in pairs(t) do
		if type(k) ~= "number" then
			io.write( indent .. "  " )
			if type(k) == "string" then
				io.write(k)
			else
				io.write("["..tostring(k).."]")
			end
			io.write( " = " )
			table.dumpvalue( v, indentLevel+1 )
			if next( t, k ) or (#t > 0) then
				print( "," )
			else
				print( "" )
			end
		end
	end
	for i,v in ipairs(t) do
		io.write( indent .. "  [" .. i .. "] = " )
		table.dumpvalue( v, indentLevel+1 )
		if i == #t then
			print( "" )
		else
			print( "," )
		end
	end
	io.write( indent .. "}" )
	if indentLevel == 0 then
		print("")
	end
end

function table.dumpvalue( value, indentLevel )
	local kind = type( value )
	if kind=="string" then
		io.write( string.format( '%q', value ) )
	elseif kind=="table" then
		table.dump( value, indentLevel )
	else
		io.write( tostring(value) )
	end
end

function table.map( t, mapFunction )
  local copy = {}
  for i,v in ipairs(t) do
    copy[i] = mapFunction(v)
  end
  return copy
end

function table.mapInPlace( t, mapFunction )
  for i,v in ipairs(t) do
    t[i] = mapFunction(v)
  end
  return t
end