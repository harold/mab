require 'test/lunity'

module( 'TEST_ACCEPTANCE', lunity )

tests = { "1a_hello_world", "13_sieve" }

function setup()
	require 'parser'
	
	runtime.stdout = ""
	core.Context.p = core.createLuaFunc( function( context )
		local args = context.message.arguments
		for i=1, #args do
			local theExpressionValue = core.evaluateChunk( args[i], context.owningContext )
			runtime.stdout = runtime.stdout .. core.toLuaString(theExpressionValue) .. "\n"
		end
		return core.Lawn['nil']
	end )

end

function makeAcceptance( testName )
	return function()
		io.input( "test/acceptance/".. testName..".mab" )
		local code = io.read("*a")
			
		io.input( "test/acceptance/".. testName..".expected" )
		local expected = io.read("*a")
		local expectedLines = {}
		for line in string.gmatch( expected, "[^\n\r]+") do
			table.insert( expectedLines, line )
		end

		parser.runString( code )

		local actualLines = {}
		for line in string.gmatch( runtime.stdout, "[^\n\r]+") do
			table.insert( actualLines, line )
		end

		for i,actualLine in ipairs(actualLines) do
			assertEqual( actualLine, expectedLines[i], string.format( "output line #%d\n  expected: %s\n       was: %s", i, expectedLines[i], actualLine) )
		end
	end
end

for i,testName in ipairs(tests) do
	_M["test"..i.."_"..testName] = makeAcceptance( testName )
end


runTests()