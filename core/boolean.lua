Roots.Boolean  = runtime.childFrom( Roots.Object, "Boolean" )
Roots['true']  = runtime.childFrom( Roots.Boolean, "true" )
Roots['false'] = runtime.childFrom( Roots.Boolean, "false" )
Roots['false']['or'] = Roots['nil']['or']
