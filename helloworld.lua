require 'parser'
-- Now read from a file!
io.input( "helloworld.mab" )
local code = io.read("*a")

local theLastCoreObjectIndex = #runtime.ObjectById
core.Lawn.program = parser.parse( code )
local theLastParsedObjectIndex = #runtime.ObjectById
core.evaluateChunk( core.Lawn.program )
local theLastRuntimeObjectIndex = #runtime.ObjectById

---[[
print( string.rep("=",70) )
print( theLastCoreObjectIndex.." core objects:" )
print( string.rep("-",70) )
for id=1,theLastCoreObjectIndex do
	print(id,runtime.ObjectById[id])
end

print( string.rep("=",70) )
print( (theLastParsedObjectIndex-theLastCoreObjectIndex).." objects created during parsing:" )
print( string.rep("-",70) )
for id=theLastCoreObjectIndex+1,theLastParsedObjectIndex do
	print(id,runtime.ObjectById[id])
end

print( string.rep("=",70) )
print( (theLastRuntimeObjectIndex-theLastParsedObjectIndex).." objects created at runtime:" )
print( string.rep("-",70) )
for id=theLastParsedObjectIndex+1,theLastRuntimeObjectIndex do
	print(id,runtime.ObjectById[id])
end
--]]
-- print( string.rep("-",70) )
-- print( "Additional objects created to show this info: "..(#runtime.ObjectById - theLastRuntimeObjectIndex) )
