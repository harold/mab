for _,testFile in ipairs{ "test_runtime.lua", "test_core.lua" } do
	dofile( "test/" .. testFile )
end