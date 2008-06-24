package.path = '../?.lua;' .. package.path
require 'lunity'

module( 'test_runtime', lunity )

function setup()
  require 'runtime'
end

function teardown()
  package.loaded.runtime = nil
end

function test1_object_ids()
  local objects = {}
  for i=1,10 do
    objects[i] = runtime.blank( )
  end
  assertEqual( #runtime.ObjectById, 10 )
  for id,object in ipairs(objects) do
    assertEqual( object, runtime.ObjectById[ id ] )
    assertEqual( runtime.ObjectId[ object ], id )
  end
  assertNotEqual( objects[0], objects[1] )
end

function test2_object_reset()
  for i=1,10 do
    runtime.blank( )
  end
  assertEqual( #runtime.ObjectById, 10 )
end

function test3_simple_inheritance()
  local gpop = runtime.blank( )
  gpop.belt = 'onion'
  gpop.name = 'harold'
  gpop.lawn = false
  
  local dad = runtime.childFrom( gpop )
  dad.belt = 'cellphone'
  dad.name = 'frank'
  
  local kid = runtime.childFrom( dad )
  kid.name  = 'moonbeam'
  
  assertEqual( kid.belt, 'cellphone' )
  assertEqual( kid.lawn, false       )
  assertEqual( kid.name, 'moonbeam'  )
  assertNil(   kid.gibble )
  
  -- Live inheritance
  dad.belt = 'MID'
  assertEqual( kid.belt, dad.belt )
  
  -- Intercept
  dad.lawn = true
  assertEqual( kid.lawn, dad.lawn )
  
  -- Path clear
  dad.belt = nil
  assertEqual( kid.belt, gpop.belt )
  
  -- Reset inheritance
  runtime.setInheritance( kid, dad )
  assertEqual( kid.belt, dad.belt ) -- both nil
end

function test4_circular_inheritance()
  local jim = runtime.blank( )
  jim.jim  = 'jim'

  local jam = runtime.blank( )
  jam.jam  = 'jam'
  
  local jem = runtime.blank( )
  jem.jem  = 'jem'
  
  -- Trivial assertions to set the stage
  assertNotNil( jim.jim )
  assertNotNil( jam.jam )
  assertNotNil( jem.jem )
  assertNil( jim.jam ); assertNil( jim.jem )
  assertNil( jam.jim ); assertNil( jam.jem )
  assertNil( jem.jim ); assertNil( jem.jam )
  
  -- A nice circular loop; it must be able to be resolved
  runtime.addInheritance( jam, jim )
  runtime.addInheritance( jem, jam )
  runtime.addInheritance( jim, jem )
  
  -- Just making we can go around the circle; no conflicts here
  assertEqual( jim.jam, jam.jam ); assertEqual( jim.jem, jem.jem )
  assertEqual( jam.jim, jim.jim ); assertEqual( jam.jem, jem.jem )
  assertEqual( jem.jim, jim.jim ); assertEqual( jem.jam, jam.jam )
end

function test5_same_level_inheritance()
  local mom = runtime.blank( )
  mom.values = 'liberal'
  
  local dad = runtime.blank( )
  dad.values = 'conservative'
  
  -- Dad is added later than mom, so loses
  local kid1 = runtime.childFrom( mom )
  assertEqual( kid1.values, mom.values )
  runtime.addInheritance( kid1, dad, nil, true )
  assertEqual( kid1.values, mom.values )
  assertTrue( runtime.isKindOf( kid1, mom ) )
  assertTrue( runtime.isKindOf( kid1, dad ) )
  
  -- Dad jumps in front of mom in priority, so wins
  local kid2 = runtime.childFrom( mom )
  runtime.addInheritance( kid2, dad )
  assertEqual( kid2.values, dad.values )
  assertTrue( runtime.isKindOf( kid2, mom ) )
  assertTrue( runtime.isKindOf( kid2, dad ) )
  
  -- Dad jumps in front of mom in priority, but then she jumps back in front
  local kid3 = runtime.childFrom( mom )
  runtime.addInheritance( kid3, dad )
  runtime.addInheritance( kid3, mom )
  assertEqual( kid3.values, mom.values )
  assertEqual( #runtime.AncestorsPerObject[kid3], 2, "Each ancestor must be listed only once per object" )
  assertTrue( runtime.isKindOf( kid3, mom ) )
  assertTrue( runtime.isKindOf( kid3, dad ) )
  
  runtime.setInheritance( kid3, nil ) -- brainwarshed!
  assertNil( kid3.values )
  assertFalse( runtime.isKindOf( kid3, mom ) )
  assertFalse( runtime.isKindOf( kid3, dad ) )
  
  -- Mom and dad pass along their values independently
  local feminineNS = 'from mom'
  local masculineNS = 'from dad'
  runtime.addInheritance( kid3, dad, masculineNS )
  runtime.addInheritance( kid3, mom, feminineNS )
  assertEqual( kid3.values, mom.values )
  kid3.values = 'nutso'
  assertEqual( runtime.valueFromNamespace( kid3, 'values', masculineNS ), dad.values )
  assertEqual( runtime.valueFromNamespace( kid3, 'values', feminineNS ), mom.values )
  assertEqual( kid3.values, 'nutso' )
  
  mom.taxes = 'high'
  assertEqual( runtime.valueFromNamespace( kid3, 'taxes', feminineNS ), mom.taxes )
  local gpop = runtime.blank( )
  gpop.taxes = 'low'
  runtime.setInheritance( dad, gpop, masculineNS )
  assertEqual( runtime.valueFromNamespace( kid3, 'taxes', masculineNS ), gpop.taxes )
end

function test6_isKindOf()
  local mom = runtime.blank( )
  local dad = runtime.blank( )
  local kid1 = runtime.childFrom( dad )
  local gpop = runtime.blank( )
  assertTrue(  runtime.isKindOf( kid1, dad ) )
  assertFalse( runtime.isKindOf( kid1, gpop ) )
  runtime.setInheritance( dad, gpop )
  assertTrue( runtime.isKindOf( kid1, gpop ) )
  assertTrue( runtime.isKindOf( kid1, kid1 ) )  
  
  local kid2 = runtime.blank( )
  runtime.addInheritance( kid2, dad )
  assertTrue( runtime.isKindOf( kid2, dad ) )


  local kid3 = runtime.blank( )
  runtime.addInheritance( kid3, dad, nil, true )
  runtime.addInheritance( kid3, mom )
  assertTrue( runtime.isKindOf( kid3, dad ) )  
  assertTrue( runtime.isKindOf( kid3, mom ) )  

  local jim = runtime.blank( )
  local jam = runtime.blank( )
  local jem = runtime.blank( )
  
  -- A nice circular loop; it must be able to be resolved
  runtime.addInheritance( jam, jim )
  runtime.addInheritance( jem, jam )
  runtime.addInheritance( jim, jem )
  
  assertTrue( runtime.isKindOf( jim, jam ) )
  assertTrue( runtime.isKindOf( jim, jem ) )
  assertTrue( runtime.isKindOf( jam, jim ) )
  assertTrue( runtime.isKindOf( jam, jem ) )
  assertTrue( runtime.isKindOf( jem, jim ) )
  assertTrue( runtime.isKindOf( jem, jam ) )
  
  local foo = runtime.blank( )
  local bar = runtime.blank( )
end

runTests()