require 'parser'
xcode = [[
	p( "Test#2" )
	p( 40 +( 2 ) )
	Lawn p( "Hello World", "This is hot!" )
]]

xcode = [[
	setSlot( "debugEval", method(
		message arguments each( chunk,
			p( "#{chunk asString} = #{chunk eval}" interpolate )
		)
	) )
	setSlot( "a", 40 )
	setSlot( "b", 2 )
	debugEval( a+b, a-b, a*b, a/b )
]]

xcode = [[
	p( "Test#3" )
	setSlot( "sing", method(
		setSlot( "bottles", 99 )
		while( bottles >( 0 ),
			p( "#{bottles} bottles of beer on the wall, #{bottles} bottles of beer!" interpolate )
			setSlot( 'bottles', bottles -( 1 ) )
			p( "Take one down, pass it around, #{bottles} bottles of beer on the wall." interpolate )
		)
		p( "Cheer!" )
	) )
	sing
]]

xcode = [[
	p( "Test#4" )
	setSlot( "bar", method(
		p( "Hello" )
		p(" World")
	 ) )
	bar
]]

xcode = [[
	p( "Test#5" )
	setSlot( "billy", Object new )
	p( billy )
	billy setSlot( 'toString', "Billy the Kid" )
	p( billy )
]]

xcode = [[
	p( "Test#6" )
	setSlot( 'go', method(
		setSlot( 'gadget', method(
			p( self )
			p( context self )
			p( context )
			p( context self self )
		))
		gadget
	))
	go
]]

xcode = [[
	p( "Test#7a" )
	setSlot( "add", method( a, b,
		a +( b )
	) )
	
	p( add(40,2) )
]]

xcode = [[
	p( "Test#7b" )
	setSlot( "add", method( a, b,
		a + b
	) )
	
	p( add(40,2) )
]]

xcode = [[
	p( "Test#8a" )
	setSlot( "mySqrt", method( x,
		
		setSlot( "goodEnough", method( guess,
			guess *( guess ) -( x ) abs <( 0.0001 )
		) )
			
		setSlot( "improve", method( guess,
			x /( guess ) +( guess ) /( 2 )
		) )
			
		setSlot( "sqrtIter", method( guess,
			if( goodEnough( guess ),
				guess,
				sqrtIter( improve(guess), x )
			)
		) )
			
		sqrtIter( 1, x )
	) )
	
	setSlot( "x", 25 )
	p( "The sqrt of #{x} is #{mySqrt( 25 )}" interpolate )
]]

xcode = [[
	p( "Test#8c" )
	mySqrt = method( x,
		
		goodEnough = method( guess,
			guess * guess - x abs < 0.0001
		)
			
		improve = method( guess,
			x / guess + guess / 2
		)
			
		sqrtIter = method( guess,
			if(
				goodEnough( guess ),
				guess,
				sqrtIter( improve(guess), x )
			)
		)
			
		sqrtIter( 1, x )
	)

	p( mySqrt( 24 ) )
]]

xcode = [[
	p( "Test#10a" )
	setSlot( "myExpr", Expression new( p( "Hello, world!" ) ) )
	myExpr eval
]]

xcode = [[
	p( "Test#10b" )
	setSlot( "myExpr", Expression new )
	setSlot( "myMessage", Message new( "p", "Hello, world!" ) )
	myExpr appendMessage( myMessage )
	myExpr eval
]]

xcode = [[
	p( "Test#10c" )
	setSlot( "myMessage", Message new )
	myMessage setSlot( "identifier", "p" )
	myMessage addArgument( "Hello, world!" )

	setSlot( "myExpr", Expression new )
	myExpr appendMessage( myMessage )

	myExpr eval
]]

xcode = [[
	p( "Test#11" )
	setSlot( "makeExpression", method( x,
		Expression new( x )
	) )
	setSlot( "x", 42 )
	setSlot( "myExp", makeExpression( 17 ) )
	p( myExp eval( Lawn ), myExp.eval( context ), myExp eval )
]]

xcode = [[
	p( 'Test#12' )
	p( 'program is:', program )
]]

local theLastCoreObjectIndex = #runtime.ObjectById
core.Lawn.program = parser.parse( code )
local theLastParsedObjectIndex = #runtime.ObjectById
core.evaluateChunk( core.Lawn.program )
local theLastRuntimeObjectIndex = #runtime.ObjectById


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

-- print( string.rep("-",70) )
-- print( "Additional objects created to show this info: "..(#runtime.ObjectById - theLastRuntimeObjectIndex) )
