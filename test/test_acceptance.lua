require 'test/lunity'

module( 'TEST_ACCEPTANCE', lunity )

tests = {
	"1a_hello_world",
	"2_this_is_hot",
	"2b_debugEval",
	"3_beer",
	"4_simple_method",
	"5_toString_override",
	"6_contexts",
	"7_simple_add",
	"7b_add_no_parens",
	"8a_newton_ugly",
	"8c_newton_pretty",
	"10a_dynamic_expression",
	"10b_appendMessage",
	"10c_dynamicMessage",
	"11_eval",
	"12_program",
	"13_sieve"
}

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

		for i,expectedLine in ipairs(expectedLines) do
			assertEqual( actualLines[i], expectedLine, string.format( "output line #%d\n  expected: %s\n       was: %s", i, expectedLine, tostring(actualLines[i])) )
		end
	end
end

for i,testName in ipairs(tests) do
	_M["test"..i.."_"..testName] = makeAcceptance( testName )
end


runTests()