require 'test/lunity'

module( 'TEST_CORE', lunity )

function setup()
  require 'core'
end

function teardown()
  package.loaded.runtime = nil
  package.loaded.core    = nil
end

function test1_chunks_and_things()
	local nilObject = core.Lawn['nil']

  local c0 = core.createChunk()
	assertEqual( #c0, 0 )
	
	local e0 = core.createExpression()
	assertEqual( #e0, 0 )
	
	local c1 = core.createChunk( e0 )
	assertEqual( #c1, 1 )
	
	assertErrors( core.createMessage )
	local m0 = core.createMessage( "go" )
	assertEqual( #m0.arguments, 0 )
	
	local e1 = core.createExpression( m0 )
	assertEqual( #e1, 1 )
	assertEqual( m0.expression, e1 )
	assertEqual( e0.chunk, c1 )
	assertEqual( m0.next, nilObject )
	assertEqual( c1.chunk, nilObject )
	assertEqual( c1.expression, nilObject )
	
	local e2 = core.createExpression( )
	core.addChildren( c1, 'chunk', e2 )
	assertEqual( #c1, 2 )
	assertEqual( e2.chunk, c1 )
	assertEqual( e0.next, e2 )
	assertEqual( e2.previous, e0 )
	assertEqual( e2.next, nilObject )
	assertEqual( e0.previous, nilObject )
	
	-- TODO: test removing a child
	-- TODO: test adding an existing child to another location (should remove from original first)
end

runTests()