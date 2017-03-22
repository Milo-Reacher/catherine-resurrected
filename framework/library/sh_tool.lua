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

catherine.tool = catherine.tool or { lists = { } }

local CAT_TOOL_METATABLE = { }

function CAT_TOOL_METATABLE:CreateConVars( )
	local mode = self:GetMode( )

	if ( CLIENT ) then
		for cvar, default in pairs( self.ClientConVar ) do
			CreateClientConVar( mode .. "_" .. cvar, default, true, true )
		end

		return
	end

	if ( SERVER ) then
		self.AllowedCVar = CreateConVar( "toolmode_allow_" .. mode, 1, FCVAR_NOTIFY )
	end
end

function CAT_TOOL_METATABLE:GetServerInfo( property )
	local mode = self:GetMode( )

	return GetConVarString( mode .. "_" .. property )
end

function CAT_TOOL_METATABLE:BuildConVarList( )
	local mode = self:GetMode( )
	local convars = { }

	for k, v in pairs( self.ClientConVar ) do
		convars[ mode .. "_" .. k ] = v
	end

	return convars
end

function CAT_TOOL_METATABLE:GetClientInfo( property )
	local mode = self:GetMode( )
	
	return self:GetOwner( ):GetInfo( mode .. "_" .. property )
end

function CAT_TOOL_METATABLE:GetClientNumber( property, default )
	local mode = self:GetMode( )
	
	return self:GetOwner( ):GetInfoNum( mode .. "_" .. property, default or 0 )
end

function CAT_TOOL_METATABLE:Allowed( )
	if ( CLIENT ) then return true end
	
	return self.AllowedCVar:GetBool( )
end

function CAT_TOOL_METATABLE:Init( ) end

function CAT_TOOL_METATABLE:GetMode( ) return self.Mode end
function CAT_TOOL_METATABLE:GetSWEP( ) return self.SWEP end
function CAT_TOOL_METATABLE:GetOwner( ) return self:GetSWEP( ).Owner or self.Owner end
function CAT_TOOL_METATABLE:GetWeapon( ) return self:GetSWEP( ).Weapon or self.Weapon end

function CAT_TOOL_METATABLE:LeftClick( ) return false end
function CAT_TOOL_METATABLE:RightClick( ) return false end
function CAT_TOOL_METATABLE:Reload( ) self:ClearObjects( ) end
function CAT_TOOL_METATABLE:Deploy( ) self:ReleaseGhostEntity( ) return end
function CAT_TOOL_METATABLE:Holster( ) self:ReleaseGhostEntity( ) return end
function CAT_TOOL_METATABLE:Think( ) self:ReleaseGhostEntity( ) end

function CAT_TOOL_METATABLE:CheckObjects( )
	for k, v in pairs( self.Objects ) do
		if ( !v.Ent:IsWorld( ) and !v.Ent:IsValid( ) ) then
			self:ClearObjects( )
		end
	end
end

function CAT_TOOL_METATABLE:UpdateData( )
	self:SetStage( self:NumObjects( ) )
end

function CAT_TOOL_METATABLE:SetStage( i )
	if ( SERVER ) then
		self:GetWeapon( ):SetNWInt( "Stage", i, true )
	end
end

function CAT_TOOL_METATABLE:GetStage( )
	return self:GetWeapon( ):GetNWInt( "Stage", 0 )
end

function CAT_TOOL_METATABLE:GetOperation( )
	return self:GetWeapon( ):GetNWInt( "Op", 0 )
end

function CAT_TOOL_METATABLE:SetOperation( i )
	if ( SERVER ) then
		self:GetWeapon( ):SetNWInt( "Op", i, true )
	end
end

function CAT_TOOL_METATABLE:ClearObjects( )
	self:ReleaseGhostEntity( )
	self.Objects = { }
	self:SetStage( 0 )
	self:SetOperation( 0 )
end

function CAT_TOOL_METATABLE:GetEnt( i )
	if ( !self.Objects[ i ] ) then return NULL end
	
	return self.Objects[ i ].Ent
end

function CAT_TOOL_METATABLE:GetPos( i )
	if ( self.Objects[ i ].Ent:EntIndex( ) == 0 ) then
		return self.Objects[ i ].Pos
	else
		if ( self.Objects[ i ].Phys != nil and self.Objects[ i ].Phys:IsValid( ) ) then
			return self.Objects[ i ].Phys:LocalToWorld( self.Objects[ i ].Pos )
		else
			return self.Objects[ i ].Ent:LocalToWorld( self.Objects[ i ].Pos )
		end
	end
end

function CAT_TOOL_METATABLE:GetLocalPos( i )
	return self.Objects[ i ].Pos
end

function CAT_TOOL_METATABLE:GetBone( i )
	return self.Objects[ i ].Bone
end

function CAT_TOOL_METATABLE:GetNormal( i )
	if ( self.Objects[ i ].Ent:EntIndex( ) == 0 ) then
		return self.Objects[ i ].Normal
	else
		local norm
		
		if ( self.Objects[ i ].Phys != nil and self.Objects[ i ].Phys:IsValid( ) ) then
			norm = self.Objects[ i ].Phys:LocalToWorld( self.Objects[ i ].Normal )
		else
			norm = self.Objects[ i ].Ent:LocalToWorld( self.Objects[ i ].Normal )
		end
		
		return norm - self:GetPos( i )
	end
end

function CAT_TOOL_METATABLE:GetPhys( i )
	if ( self.Objects[ i ].Phys == nil ) then
		return self:GetEnt( i ):GetPhysicsObject( )
	end

	return self.Objects[ i ].Phys
end

function CAT_TOOL_METATABLE:SetObject( i, ent, pos, phys, bone, norm )
	self.Objects[ i ] = { }
	self.Objects[ i ].Ent = ent
	self.Objects[ i ].Phys = phys
	self.Objects[ i ].Bone = bone
	self.Objects[ i ].Normal = norm

	if ( ent:EntIndex( ) == 0 ) then
		self.Objects[ i ].Phys = nil
		self.Objects[ i ].Pos = pos
	else
		norm = norm + pos

		if ( IsValid( phys ) ) then
			self.Objects[ i ].Normal = self.Objects[ i ].Phys:WorldToLocal( norm )
			self.Objects[ i ].Pos = self.Objects[ i ].Phys:WorldToLocal( pos )
		else
			self.Objects[ i ].Normal = self.Objects[ i ].Ent:WorldToLocal( norm )
			self.Objects[ i ].Pos = self.Objects[ i ].Ent:WorldToLocal( pos )
		end
	end
end

function CAT_TOOL_METATABLE:NumObjects( )
	if ( CLIENT ) then
		return self:GetStage( )
	end

	return #self.Objects
end

function CAT_TOOL_METATABLE:GetHelpText( )
	return "#tool." .. GetConVarString( "gmod_toolmode" ) .. "." .. self:GetStage( )
end

function CAT_TOOL_METATABLE:MakeGhostEntity( model, pos, angle )
	util.PrecacheModel( model )

	if ( SERVER and !game.SinglePlayer( ) ) then return end
	if ( CLIENT and game.SinglePlayer( ) ) then return end

	self:ReleaseGhostEntity( )

	if ( !util.IsValidProp( model ) ) then return end
	
	if ( CLIENT ) then
		self.GhostEntity = ents.CreateClientProp( model )
	else
		self.GhostEntity = ents.Create( "prop_physics" )
	end

	if ( !self.GhostEntity:IsValid( ) ) then
		self.GhostEntity = nil
		return
	end
	
	self.GhostEntity:SetModel( model )
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn( )
	
	self.GhostEntity:SetSolid( SOLID_VPHYSICS )
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true )
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.GhostEntity:SetColor( Color( 255, 255, 255, 150 ) )
end

function CAT_TOOL_METATABLE:StartGhostEntity( ent )
	if ( SERVER and !game.SinglePlayer( ) ) then return end
	if ( CLIENT and game.SinglePlayer( ) ) then return end
	
	self:MakeGhostEntity( ent:GetModel( ), ent:GetPos( ), ent:GetAngles( ) )
end

function CAT_TOOL_METATABLE:ReleaseGhostEntity( )
	if ( self.GhostEntity ) then
		if ( !self.GhostEntity:IsValid( ) ) then self.GhostEntity = nil return end
		self.GhostEntity:Remove( )
		self.GhostEntity = nil
	end
	
	if ( self.GhostEntities ) then
		for k, v in pairs( self.GhostEntities ) do
			if ( v:IsValid( ) ) then v:Remove( ) end
			
			self.GhostEntities[ k ] = nil
		end
		
		self.GhostEntities = nil
	end
	
	if ( self.GhostOffset ) then
		for k, v in pairs( self.GhostOffset ) do
			self.GhostOffset[ k ] = nil
		end
	end
end

function CAT_TOOL_METATABLE:UpdateGhostEntity( )
	if ( self.GhostEntity == nil ) then return end
	if ( !self.GhostEntity:IsValid( ) ) then self.GhostEntity = nil return end
	
	local tr = util.GetPlayerTrace( self:GetOwner( ) )
	local trace = util.TraceLine( tr )
	
	if ( !trace.Hit ) then return end
	
	local Ang1, Ang2 = self:GetNormal( 1 ):Angle( ), ( trace.HitNormal * -1 ):Angle( )
	local TargetAngle = self:GetEnt( 1 ):AlignAngles( Ang1, Ang2 )
	
	self.GhostEntity:SetPos( self:GetEnt( 1 ):GetPos( ) )
	self.GhostEntity:SetAngles( TargetAngle )

	local TranslatedPos = self.GhostEntity:LocalToWorld( self:GetLocalPos( 1 ) )
	local TargetPos = trace.HitPos + ( self:GetEnt( 1 ):GetPos( ) - TranslatedPos ) + ( trace.HitNormal )
	
	self.GhostEntity:SetPos( TargetPos )
end

if ( CLIENT ) then
	function CAT_TOOL_METATABLE:FreezeMovement( )
		return false
	end
	
	function CAT_TOOL_METATABLE:DrawHUD( )
	
	end
end

function CAT_TOOL_METATABLE:Create( mode )
	local object = { }
	
	setmetatable( object, self )
	self.__index = self
	
	object.UniqueID = mode
	object.Mode = mode
	object.SWEP = nil
	object.Owner = nil
	object.ClientConVar = { }
	object.ServerConVar = { }
	object.Objects = { }
	object.Stage = 0
	object.Message = "start"
	object.LastMessage = 0
	object.AllowedCVar = 0

	return object
end

function catherine.tool.Register( toolTable )
	toolTable.Mode = toolTable.UniqueID
	toolTable:CreateConVars( )

	catherine.tool.lists[ toolTable.UniqueID ] = toolTable
end

function catherine.tool.New( uniqueID )
	return CAT_TOOL_METATABLE:Create( uniqueID )
end

function catherine.tool.GetAll( )
	return catherine.tool.lists
end

function catherine.tool.FindByID( uniqueID )
	return catherine.tool.lists[ uniqueID ]
end