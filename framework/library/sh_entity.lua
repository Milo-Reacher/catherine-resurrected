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

catherine.entity = catherine.entity or { }
local META = FindMetaTable( "Entity" )
local getClass = META.GetClass
local getModel = META.GetModel
local chairs = { }

do
	for k, v in pairs( list.Get( "Vehicles" ) ) do
		if ( v.Category == "Chairs" ) then
			chairs[ v.Model ] = true
		end
	end
end

function catherine.entity.IsDoor( ent )
	local class = getClass( ent )
	
	return class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
end

function catherine.entity.IsProp( ent )
	return getClass( ent ):find( "prop_" )
end

function catherine.entity.IsChair( ent )
	return chairs[ getModel( ent ) ]
end

function META:IsDoor( )
	local class = getClass( self )
	
	return class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating"
end

function META:IsProp( )
	return getClass( self ):find( "prop_" )
end

function META:IsChair( )
	return chairs[ getModel( self ) ]
end

if ( SERVER ) then
	catherine.entity.mapEntities = catherine.entity.mapEntities or { }
	catherine.entity.customUse = catherine.entity.customUse or { }
	
	function catherine.entity.SetMapEntity( ent, bool )
		catherine.entity.mapEntities[ ent ] = bool
	end
	
	function catherine.entity.IsMapEntity( ent )
		return catherine.entity.mapEntities[ ent ] != nil
	end
	
	function catherine.entity.StartFadeOut( ent, time, func )
		if ( ent.CAT_isFadeouting ) then return end
		local col = ent:GetColor( )
		local alpha = 0
		local fadeAmount = col.a / time
		local timerID = "Catherine.timer.entity.EntFadeOut." .. ent:EntIndex( )
		
		ent.CAT_originalColor = col
		ent.CAT_originalRenderMode = ent:GetRenderMode( )
		ent.CAT_isFadeouting = true
		ent:SetNetVar( "isFadeouting", true )
		ent:SetRenderMode( RENDERMODE_TRANSALPHA )
		
		timer.Remove( timerID )
		timer.Create( timerID, fadeAmount, time, function( )
			if ( !IsValid( ent ) ) then
				timer.Remove( timerID )
				return
			end
			
			if ( alpha > 0 ) then
				alpha = alpha - fadeAmount
				ent:SetColor( Color( col.r, col.g, col.b, alpha ) )
			else
				ent.CAT_isFadeouting = nil
				ent:SetNetVar( "isFadeouting", nil )
				timer.Remove( timerID )
				
				if ( func ) then
					func( ent, time )
				end
			end
		end )
	end
	
	function catherine.entity.StopFadeOut( ent, func )
		if ( !ent.CAT_isFadeouting ) then return end
		
		timer.Remove( "Catherine.timer.entity.EntFadeOut." .. ent:EntIndex( ) )
		
		if ( ent.CAT_originalColor and ent.CAT_originalRenderMode ) then
			ent:SetColor( ent.CAT_originalColor )
			ent:SetRenderMode( ent.CAT_originalRenderMode )
			
			ent.CAT_originalRenderMode = nil
			ent.CAT_originalColor = nil
		end
		
		ent.CAT_isFadeouting = nil
		ent:SetNetVar( "isFadeouting", nil )
		
		if ( func ) then
			func( ent )
		end
	end
	
	function catherine.entity.IsFadeOuting( ent )
		return ent.CAT_isFadeouting
	end
	
	function catherine.entity.SetIgnoreUse( ent, bool )
		ent.CAT_ignoreUse = bool
	end
	
	function catherine.entity.GetIgnoreUse( ent )
		return ent.CAT_ignoreUse
	end
	
	function catherine.entity.RegisterUseMenu( ent, menuTable )
		local forServer = { }
		local forClient = { }
		
		for k, v in pairs( menuTable ) do
			forServer[ v.uniqueID ] = v.func
			forClient[ v.uniqueID ] = {
				text = v.text,
				uniqueID = v.uniqueID,
				icon = v.icon
			}
		end
		
		ent.isCustomUse = true
		catherine.entity.customUse[ ent:EntIndex( ) ] = forServer
		
		ent:SetNetVar( "customUseClient", forClient )
	end
	
	function catherine.entity.IsRegisteredUseMenu( ent )
		return catherine.entity.customUse[ ent:EntIndex( ) ]
	end
	
	function catherine.entity.OpenUseMenu( pl, ent )
		netstream.Start( pl, "catherine.entity.CustomUseMenu", ent:EntIndex( ) )
	end
	
	function catherine.entity.RunUseMenu( pl, index, uniqueID )
		if ( !catherine.entity.customUse[ index ] or !catherine.entity.customUse[ index ][ uniqueID ] ) then return end
		
		catherine.entity.customUse[ index ][ uniqueID ]( pl, Entity( index ) )
	end
	
	function META:IsMapEntity( )
		return catherine.entity.mapEntities[ self ] != nil
	end
	
	function catherine.entity.EntityRemoved( ent )
		catherine.entity.customUse[ ent:EntIndex( ) ] = nil
	end
	
	hook.Add( "EntityRemoved", "catherine.entity.EntityRemoved", catherine.entity.EntityRemoved )
	
	netstream.Hook( "catherine.entity.customUseMenu_Receive", function( pl, data )
		catherine.entity.RunUseMenu( pl, data[ 1 ], data[ 2 ] )
	end )
else
	netstream.Hook( "catherine.entity.CustomUseMenu", function( data )
		local pl = catherine.pl
		local index = data
		local ent = Entity( index )
		local menu = DermaMenu( )
		local activeWep = pl:GetActiveWeapon( )
		
		if ( IsValid( activeWep ) and activeWep:GetClass( ) == "weapon_physgun" and pl:KeyDown( IN_ATTACK ) ) then return end
		
		local isAv = false
		
		for k, v in pairs( IsValid( ent ) and ent:GetNetVar( "customUseClient" ) or { } ) do
			menu:AddOption( catherine.util.StuffLanguage( v.text ), function( )
				netstream.Start( "catherine.entity.customUseMenu_Receive", {
					index,
					v.uniqueID
				} )
			end ):SetImage( v.icon or "icon16/information.png" )
			
			isAv = true
		end
		
		menu:Open( )
		menu:Center( )
		
		if ( isAv ) then
			catherine.util.SetDermaMenuTitle( menu, LANG( "Basic_UI_EntityMenuOptionTitle" ) )
		end
	end )
	
	function catherine.entity.IsFadeOuting( ent )
		return ent:GetNetVar( "isFadeouting", false )
	end
	
	function catherine.entity.LanguageChanged( )
		for k, v in pairs( ents.GetAll( ) ) do
			if ( !v.LanguageChanged ) then continue end
			
			v:LanguageChanged( )
		end
	end
	
	hook.Add( "LanguageChanged", "catherine.entity.LanguageChanged", catherine.entity.LanguageChanged )
end

function catherine.entity.GetPlayer( ent )
	return ent:GetNetVar( "player" )
end

META.CATSetModel = META.CATSetModel or META.SetModel
META.CATGetModel = META.CATGetModel or META.GetModel

function META:SetModel( model )
	if ( SERVER and self:IsPlayer( ) ) then
		netstream.Start( self, "catherine.SetModel", { self, model } )
	end
	
	self:CATSetModel( model )
end

function META:GetModel( )
	local originalModel = self:CATGetModel( )
	
	if ( IsValid( self ) ) then
		return self:GetNetVar( "fakeModel", originalModel )
	end
	
	return originalModel
end

local META2 = FindMetaTable( "Weapon" )

META2.CATGetPrintName = META2.CATGetPrintName or META2.GetPrintName

local languageStuff = catherine.util.StuffLanguage

function META2:GetPrintName( )
	return languageStuff( self:CATGetPrintName( ) )
end