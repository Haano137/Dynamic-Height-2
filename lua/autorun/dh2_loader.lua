AddCSLuaFile()

if CLIENT then

	include("dynamic_height_2/client.lua")

elseif SERVER then

	include("dynamic_height_2/server.lua")

end
