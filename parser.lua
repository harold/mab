require 'lpeg'
require 're'

require 'core'
require 'runtime'
local re,runtime,core,io,table,ipairs,tostring,tonumber,error,table,string = re,runtime,core,io,table,ipairs,tostring,tonumber,error,table,string
local print=print
module('parser')

grammar = [[
	Chunk         <-   &. -> startChunk <Expression> (<Terminator> <Expression>)* -> endChunk
	Expression    <-   &. -> startExpr <Space> (<Message>/<String>/<Number>)+ -> endExpr
	ArgExpression <-   <Chunk> -> addArgChunk ("," <Space> / &<CloseParen>)
	Message       <-   ( <Identifier>/ <Operator> ) -> startMessage <Arguments>?  <Separator>* -> endMessage
	Arguments     <-   <OpenParen> <ArgExpression>* <CloseParen>
	Identifier    <-   [a-zA-Z_]+
	Operator      <-   [=~`!@$%^&*|<>?/\\+-]+
	Separator     <-   [ .]
	Terminator    <-   ( (%nl / ";") <Space> ) / !.
	
	String        <-   (('"' ([^"]* -> addString) '"') / ("'" ([^']* -> addString) "'")) <Separator>*
	Number        <-   ( ( [+-]? [0-9] [0-9_]* ('.' [0-9] [0-9_]*)? ) / ( [+-]? '.' [0-9] [0-9_]* ) ) -> addNumber <Separator>*

	OpenParen     <-   "(" <Space>
	CloseParen    <-   <Space> ")"
	Space         <-   (%s)*
]]

ast = {}
exprStack = {}
chunkStack = {}
argsStack = {}
messageStack = {}
stringStack = {}

parseFuncs = {}
function parseFuncs.startChunk( )
	local chunk = { tag="chunk" }
	table.insert( chunkStack, chunk )
end

function parseFuncs.endChunk( inMatch )
	table.insert( ast, table.remove( chunkStack ) )
end

function parseFuncs.startExpr( inMatch )
	local expression = { tag="expression" }
	table.insert( exprStack, expression )
end

function parseFuncs.endExpr( inMatch )
	table.insert( chunkStack[#chunkStack], table.remove( exprStack ) )
end

function parseFuncs.startMessage( inMatch )
	local message = { tag="message", str=inMatch }
	table.insert( messageStack, message )
end

function parseFuncs.endMessage( inMatch )
	table.insert( exprStack[#exprStack], table.remove( messageStack ) )
end

function parseFuncs.addArgChunk( )
	table.insert( messageStack[#messageStack], table.remove( ast ) )
end

function parseFuncs.addString( inMatch )
	local string = { tag="string", str=inMatch }
	table.insert( exprStack[#exprStack], string )
end

function parseFuncs.addNumber( inMatch )
	local number = { tag="number", str=inMatch }
	table.insert( exprStack[#exprStack], number )
end

function parseFile( file )
	return parse( io.input(file):read("*a") )
end

function parse( code )
	local matchLength = re.compile( grammar, parseFuncs ):match( code )
	if not matchLength or (matchLength < #code) then
		table.dump( ast )
		error( "Failed to parse code! (Got to around char "..tostring(matchLength).." / "..(#code)..")" )
	end
	return codeFromAST( table.remove( ast ) )
end

function codeFromAST( t )
	if t.tag=="chunk" then
		local chunk = core.createChunk()
		for i,childAST in ipairs(t) do
			chunk[i] = codeFromAST( childAST )
			chunk[i].chunk = chunk
			if i>1 then
			  chunk[i-1].next = chunk[i]
			  chunk[i].previous = chunk[i-1]
			end
		end
		
		return chunk
		
	elseif t.tag=="expression" then
		local expression = core.createExpression()
		for i,childAST in ipairs(t) do
			expression[i] = codeFromAST( childAST )
			expression[i].expression = expression
			if i>1 then
				expression[i-1].next = expression[i]
				expression[i].previous = expression[i-1]
			end
		end
		return expression
		
	elseif t.tag=="message" then
		local message = core.createMessage( t.str )
		for i,childAST in ipairs(t) do
			message.arguments[i] = codeFromAST( childAST )
		end
		return message

	elseif t.tag=="string" then
		return runtime.string[t.str]
		
	elseif t.tag=="number" then
		return runtime.number[tonumber(t.str)]
		
	else
		error( "AST with unknown tag encountered: "..tostring(t.tag) )
	end
end

core.String.interpolate = core.createLuaFunc( function( context )
	local str = runtime.luastring[ context.self ]
	str = string.gsub( str, "#(%b{})", function( chunkWithBrackets )
		local chunk = parse( string.sub( chunkWithBrackets, 2, -2 ) )
		local value = core.evaluateChunk( chunk, context.owningContext )
		return core.toLuaString( value )
	end)
	return runtime.string[ str ]
end )