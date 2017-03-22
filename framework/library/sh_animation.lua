--[[
< CATHERINE > - A free role-playing framework for Garry's Mod.
Development and design by L7D.

Catherine is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Catherine.  If not, see <http://www.gnu.org/licenses/>.
]]--

--[[
	This code has brought from NutScript.
	https://github.com/Chessnut/NutScript
]]--

catherine.animation = catherine.animation or { lists = { } }

function catherine.animation.Register( class, mdl )
	catherine.animation.lists[ mdl:lower( ) ] = class
end

function catherine.animation.RegisterDataTable( class, dataTable )
	catherine.animation[ class ] = dataTable
end

function catherine.animation.Get( mdl )
	mdl = mdl:lower( )
	
	return catherine.animation.lists[ mdl ] or ( mdl:find( "female" ) and "citizen_female" or "citizen_male" )
end

function catherine.animation.IsClass( ent, class )
	return catherine.animation.lists[ ent:GetModel( ):lower( ) ] == class
end

catherine.animation.RegisterDataTable( "citizen_male", {
	normal = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_COVER_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED }
	},
	pistol = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		idle = { ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		walk = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		idle = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		walk = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		idle = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
		idle_crouch = { ACT_COVER_LOW, ACT_COVER_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		idle = { ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE },
		idle_crouch = { ACT_COVER_LOW, ACT_COVER_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN, ACT_RUN },
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = {
		[ "prop_vehicle_prisoner_pod" ] = { "podpose", Vector( -3, 0, 0 ) },
		[ "prop_vehicle_jeep" ] = { "sitchair1", Vector( 14, 0, -14 ) },
		[ "prop_vehicle_airboat" ] = { "sitchair1", Vector( 8, 0, -20 ) },
		chair = { "sitchair1", Vector( 1, 0, -23 ) }
	},
} )

catherine.animation.RegisterDataTable( "citizen_female", {
	normal = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_COVER_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED }
	},
	pistol = {
		idle = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
		idle_crouch = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_PISTOL },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN, ACT_RUN_AIM_PISTOL },
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		idle = { ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		walk = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		idle = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
		walk = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_LOW, ACT_COVER_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
		run = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		idle = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
		idle_crouch = { ACT_COVER_LOW, ACT_COVER_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN, ACT_RUN },
		attack = ACT_MELEE_ATTACK_SWING
	},
	glide = ACT_GLIDE,
	vehicle = catherine.animation.citizen_male.vehicle
} )

catherine.animation.RegisterDataTable( "metrocop", {
	normal = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW },
		walk = { ACT_WALK, ACT_WALK_AIM_RIFLE },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN, ACT_RUN }
	},
	pistol = {
		idle = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
		idle_crouch = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
		walk = { ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL }
	},
	smg = {
		idle = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
		walk = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	shotgun = {
		idle = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
		walk = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE_STIMULATED }
	},
	grenade = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_MELEE },
		idle_crouch = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
		walk = { ACT_WALK, ACT_WALK_ANGRY},
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN, ACT_RUN },
		attack = ACT_COMBINE_THROW_GRENADE
	},
	melee = {
		idle = { ACT_IDLE, ACT_IDLE_ANGRY_MELEE },
		idle_crouch = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
		walk = { ACT_WALK, ACT_WALK_ANGRY},
		walk_crouch = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
		run = { ACT_RUN, ACT_RUN },
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE,
	vehicle = {
		chair = { ACT_COVER_PISTOL_LOW, Vector( 5, 0, -5 ) },
		[ "prop_vehicle_airboat" ] = { ACT_COVER_PISTOL_LOW, Vector( 10, 0, 0 ) },
		[ "prop_vehicle_jeep" ] = { ACT_COVER_PISTOL_LOW, Vector( 18, -2, 4 ) },
		[ "prop_vehicle_prisoner_pod" ] = { ACT_IDLE, Vector( -4, -0.5, 0 ) }
	}
} )

catherine.animation.RegisterDataTable( "overwatch", {
	normal = {
		idle = { "idle_unarmed", "man_gun" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { "walkunarmed_all", ACT_WALK_RIFLE },
		walk_crouch = { "crouch_walkall", "crouch_walkall" },
		run = { "runall", ACT_RUN_AIM_RIFLE }
	},
	pistol = {
		idle = { "idle_unarmed", ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { "walkunarmed_all", ACT_WALK_RIFLE },
		walk_crouch = { "crouch_walkall", "crouch_walkall" },
		run = { "runall", ACT_RUN_AIM_RIFLE }
	},
	smg = {
		idle = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
		walk_crouch = { "crouch_walkall", "crouch_walkall" },
		run = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
	},
	shotgun = {
		idle = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN },
		walk_crouch = { "crouch_walkall", "crouch_walkall" },
		run = { ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN }
	},
	grenade = {
		idle = { "idle_unarmed", "man_gun" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { "walkunarmed_all", ACT_WALK_RIFLE },
		walk_crouch = { "crouch_walkall", "crouch_walkall" },
		run = { "runall", ACT_RUN_AIM_RIFLE }
	},
	melee = {
		idle = { "idle_unarmed", "man_gun" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { "walkunarmed_all", ACT_WALK_RIFLE },
		walk_crouch = { "crouch_walkall", "crouch_walkall" },
		run = { "runall", ACT_RUN_AIM_RIFLE },
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	glide = ACT_GLIDE
} )

catherine.animation.RegisterDataTable( "vort", {
	normal = {
		idle = { ACT_IDLE, "actionidle" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK, "walk_all_holdgun" },
		walk_crouch = { ACT_WALK, "walk_all_holdgun" },
		run = { ACT_RUN, ACT_RUN }
	},
	pistol = {
		idle = { ACT_IDLE, "tcidle" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK, "walk_all_holdgun" },
		walk_crouch = { ACT_WALK, "walk_all_holdgun" },
		run = { ACT_RUN, "run_all_tc" }
	},
	smg = {
		idle = { ACT_IDLE, "tcidle" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK, "walk_all_holdgun" },
		walk_crouch = { ACT_WALK, "walk_all_holdgun" },
		run = { ACT_RUN, "run_all_tc" }
	},
	shotgun = {
		idle = { ACT_IDLE, "tcidle" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK, "walk_all_holdgun" },
		walk_crouch = { ACT_WALK, "walk_all_holdgun" },
		run = { ACT_RUN, "run_all_tc" }
	},
	grenade = {
		idle = { ACT_IDLE, "tcidle" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK, "walk_all_holdgun" },
		walk_crouch = { ACT_WALK, "walk_all_holdgun" },
		run = { ACT_RUN, "run_all_tc" }
	},
	melee = {
		idle = { ACT_IDLE, "tcidle" },
		idle_crouch = { "crouchidle", "crouchidle" },
		walk = { ACT_WALK, "walk_all_holdgun" },
		walk_crouch = { ACT_WALK, "walk_all_holdgun" },
		run = { ACT_RUN, "run_all_tc" }
	},
	glide = ACT_GLIDE
} )

for i = 1, 4 do
	for k, v in pairs( file.Find( "models/humans/group0" .. i .. "/male_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_male", "models/humans/group0" .. i .. "/" .. v )
	end
	
	for k, v in pairs( file.Find( "models/humans/group0" .. i .. "/female_*.mdl", "GAME" ) ) do
		catherine.animation.Register( "citizen_female", "models/humans/group0" .. i .. "/" .. v )
	end
end

catherine.animation.Register( "citizen_female", "models/mossman.mdl" )
catherine.animation.Register( "citizen_female", "models/alyx.mdl" )
catherine.animation.Register( "metrocop", "models/police.mdl" )
catherine.animation.Register( "overwatch", "models/combine_super_soldier.mdl" )
catherine.animation.Register( "overwatch", "models/combine_soldier_prisonguard.mdl" )
catherine.animation.Register( "overwatch", "models/combine_soldier.mdl" )
catherine.animation.Register( "vort", "models/vortigaunt.mdl" )
catherine.animation.Register( "vort", "models/vortigaunt_slave.mdl" )
catherine.animation.Register( "metrocop", "models/dpfilms/metropolice/playermodels/pm_skull_police.mdl" )
catherine.animation.Register( "metrocop", "models/dpfilms/metropolice/hl2concept.mdl" )

if ( SERVER ) then
	function catherine.animation.StartSequence( pl, seqID, time, preFunc, postFunc )
		local valid, len = pl:LookupSequence( seqID )
		
		time = time or len
		
		if ( !valid or valid == -1 ) then
			return
		end
		
		pl:SetNetVar( "seqAni", seqID )
		
		if ( preFunc ) then
			preFunc( )
		end
		
		if ( time > 0 ) then
			local timerID = "Catherine.timer.animation.Sequence." .. pl:SteamID( )
			
			timer.Remove( timerID )
			timer.Create( timerID, time, 1, function( )
				if ( !IsValid( pl ) ) then return end
				
				catherine.animation.StopSequence( pl )
				
				if ( postFunc ) then
					postFunc( )
				end
			end )
		end
		
		return time, valid
	end
	
	function catherine.animation.StopSequence( pl )
		timer.Remove( "Catherine.timer.animation.Sequence." .. pl:SteamID( ) )
		pl:SetNetVar( "seqAni", false )
	end
end

function catherine.animation.GetSequence( pl )
	return pl:GetNetVar( "seqAni", false )
end
