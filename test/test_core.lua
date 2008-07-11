require 'test/lunity'

module( 'TEST_CORE', lunity )

function setup()
  require 'core'
end

function teardown()
  package.loaded.runtime = nil
  package.loaded.core    = nil
end

function test1_expressions_and_things()
	local nilObject = core.Roots['nil']

	local e0 = core.createExpression()
	assertEqual( #e0, 0 )
	
	assertErrors( core.createMessage )
	local m0 = core.createMessage( "go" )
	assertEqual( #m0.arguments, 0 )
	
	local e1 = core.createExpression()
	core.addChildren( e1, m0 )
	assertEqual( #e1, 1 )
	assertEqual( m0.parent, e1 )
	assertEqual( e0.parent, nilObject )
	assertEqual( m0.next, nilObject )
	
	local e2 = core.createExpression( )
	core.addChildren( e1, e0, e2 )
	assertEqual( #e1, 3 )
	assertEqual( e2.parent, e1 )
	assertEqual( e0.next, e2 )
	assertEqual( e2.previous, e0 )
	assertEqual( e2.next, nilObject )
	assertEqual( e0.previous, m0 )
	assertEqual( m0.next, e0 )
	
	-- TODO: test removing a child
	-- TODO: test adding an existing child to another location (should remove from original first)
end

function test2_while()
	-- While requires 2 arguments
	local mabFalse = core.Roots['false']
	local lawn     = core.Roots.Lawn	
	assertErrors( core.sendMessageAsString, lawn, 'while' )
	assertErrors( core.sendMessageAsString, lawn, 'while', mabFalse )
	assertDoesNotError( core.sendMessageAsString, lawn, 'while', mabFalse, mabFalse )
	assertErrors( core.sendMessageAsString, lawn, 'while', mabFalse, mabFalse, mabFalse )
end

runTests()