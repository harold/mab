require 'test/lunity'
lunity.useANSIColors = false
lunity.useHTML       = true

for _,testFile in ipairs{
	"test_runtime.lua",
	"test_core.lua",
	"test_acceptance.lua"
} do
	dofile( "test/" .. testFile )
end