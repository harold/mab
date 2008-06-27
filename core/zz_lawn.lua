Lawn.Lawn       = Lawn
Lawn.context    = Lawn
Lawn.Object     = Object
Lawn.String     = String
Lawn.Number     = Number
Lawn.Boolean    = Boolean
Lawn.Array      = Array
Lawn.Function   = Function
Lawn.Chunk      = Chunk
Lawn.Expression = Expression
Lawn.Message    = Message
Lawn.ArgList    = ArgList
Lawn.Context    = Context
Lawn.Call       = Call
Lawn['true']    = runtime.childFrom( Boolean, "true" )
Lawn['false']   = runtime.childFrom( Boolean, "false" )

--TODO: Should this really inherit from object, or not?
Lawn['nil']     = runtime.childFrom( Object,  "nil (the object)" )

runtime.Meta.nilValue    = Lawn['nil']

Function.executeOnAccess = Lawn['true']

Lawn['nil']['or'] = createLuaFunc( 'rValue', function( context ) 
	return context.rValue
end )

Lawn['false']['or'] = Lawn['nil']['or']
