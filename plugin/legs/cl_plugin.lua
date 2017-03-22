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

local PLUGIN = PLUGIN
PLUGIN.legEnt = PLUGIN.legEnt or nil
PLUGIN.playBackRate = 1
PLUGIN.sequence = nil
PLUGIN.velocity = 0
PLUGIN.oldWeapon = nil
PLUGIN.breathScale = 0.5
PLUGIN.nextBreath = 0
PLUGIN.renderAngle = nil
PLUGIN.biaisAngle = nil
PLUGIN.radAngle = nil
PLUGIN.renderPos = nil
PLUGIN.renderColor = { }
PLUGIN.clipVector = vector_up * -1
PLUGIN.forwardOffset = -20
PLUGIN.nextMatSet = CurTime( )
PLUGIN.lastCharID = PLUGIN.lastCharID or 0
local hiddenBones = {
	"ValveBiped.Bip01_Spine1",
	"ValveBiped.Bip01_Spine2",
	"ValveBiped.Bip01_Spine4",
	"ValveBiped.Bip01_Neck1",
	"ValveBiped.Bip01_Head1",
	"ValveBiped.forward",
	"ValveBiped.Bip01_R_Clavicle",
	"ValveBiped.Bip01_R_UpperArm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Anim_Attachment_RH",
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Anim_Attachment_LH",
	"ValveBiped.Bip01_L_Finger4",
	"ValveBiped.Bip01_L_Finger41",
	"ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0",
	"ValveBiped.Bip01_L_Finger01",
	"ValveBiped.Bip01_L_Finger02",
	"ValveBiped.Bip01_R_Finger4",
	"ValveBiped.Bip01_R_Finger41",
	"ValveBiped.Bip01_R_Finger42",
	"ValveBiped.Bip01_R_Finger3",
	"ValveBiped.Bip01_R_Finger31",
	"ValveBiped.Bip01_R_Finger32",
	"ValveBiped.Bip01_R_Finger2",
	"ValveBiped.Bip01_R_Finger21",
	"ValveBiped.Bip01_R_Finger22",
	"ValveBiped.Bip01_R_Finger1",
	"ValveBiped.Bip01_R_Finger11",
	"ValveBiped.Bip01_R_Finger12",
	"ValveBiped.Bip01_R_Finger0",
	"ValveBiped.Bip01_R_Finger01",
	"ValveBiped.Bip01_R_Finger02",
	"ValveBiped.baton_parent"
}

local META = FindMetaTable( "Player" )

function META:ShouldDrawLegs( )
	return IsValid( PLUGIN.legEnt ) and
	self:Alive( ) and
	!self:InVehicle( ) and
	self:GetViewEntity( ) == self and
	!self:ShouldDrawLocalPlayer( ) and
	!self:GetObserverTarget( ) and
	GetConVarString( "cat_convar_legs" ) == "1"
end

function PLUGIN:Initialize( )
	CAT_CONVAR_LEGS = CreateClientConVar( "cat_convar_legs", "1", true, true )
end

function PLUGIN:CreateLegs( )
	local pl = catherine.pl
	
	local legEnt = ClientsideModel( pl:GetModel( ), RENDER_GROUP_OPAQUE_ENTITY )
	legEnt:SetNoDraw( true )
	legEnt:SetSkin( pl:GetSkin( ) or 0 )
	legEnt:SetMaterial( pl:GetMaterial( ) )
	legEnt:SetColor( pl:GetColor( ) )
	
	for k, v in pairs( pl:GetBodyGroups( ) ) do
		legEnt:SetBodygroup( v.id, pl:GetBodygroup( v.id ) )
	end
	
	for k, v in pairs( pl:GetMaterials( ) ) do
		legEnt:SetSubMaterial( k - 1, pl:GetSubMaterial( k - 1 ) )
	end
	
	legEnt.lastTick = 0
	
	self.lastCharID = pl:GetCharacterID( )
	
	self.legEnt = legEnt
end

function PLUGIN:PlayerWeaponChanged( pl, weapon )
	if ( IsValid( self.legEnt ) ) then
		local legEnt = self.legEnt
		
		for i = 0, legEnt:GetBoneCount( ) do
			legEnt:ManipulateBoneScale( i, Vector( 1, 1, 1 ) )
			legEnt:ManipulateBonePosition( i, Vector( 0, 0, 0 ) )
		end
		
		for k, v in pairs( hiddenBones ) do
			local bone = legEnt:LookupBone( v )
			
			if ( bone ) then
				legEnt:ManipulateBoneScale( bone, vector_origin )
				legEnt:ManipulateBonePosition( bone, Vector( -10, -10, 0 ) )
			end
		end
	end
end

function PLUGIN:UpdateAnimation( pl, velocity, speed )
	if ( pl == catherine.pl ) then
		if ( IsValid( self.legEnt ) ) then
			self:LegsWork( pl, speed )
		else
			self:CreateLegs( )
		end
	end
end

function PLUGIN:LegsWork( pl, speed )
	if ( !pl:IsCharacterLoaded( ) or !pl:ShouldDrawLegs( ) ) then return end
	if ( !pl:Alive( ) ) then
		self:CreateLegs( )
		return
	end
	
	if ( !IsValid( self.legEnt ) ) then return end
	
	if ( self.lastCharID != pl:GetCharacterID( ) ) then
		self.legEnt:Remove( )
		self:CreateLegs( )
		
		self.playBackRate = 1
		self.sequence = nil
		self.velocity = 0
		self.oldWeapon = nil
		self.breathScale = 0.5
		self.nextBreath = 0
		self.renderAngle = nil
		self.biaisAngle = nil
		self.radAngle = nil
		self.renderPos = nil
		self.renderColor = { }
		self.clipVector = vector_up * -1
		self.forwardOffset = -20
		self.nextMatSet = CurTime( ) + 10
		
		self.lastCharID = pl:GetCharacterID( )
	end
	
	local legEnt = self.legEnt
	local curTime = CurTime( )
	
	if ( pl:GetActiveWeapon( ) != self.oldWeapon ) then
		self.oldWeapon = pl:GetActiveWeapon( )
		self:PlayerWeaponChanged( pl, self.oldWeapon )
	end
	
	if ( legEnt:GetModel( ) != pl:GetModel( ) ) then
		legEnt:SetModel( pl:GetModel( ) )
	end
	
	if ( legEnt:GetMaterial( ) != pl:GetMaterial( ) ) then
		legEnt:SetMaterial( pl:GetMaterial( ) )
	end
	
	if ( legEnt:GetSkin( ) != pl:GetSkin( ) ) then
		legEnt:SetSkin( pl:GetSkin( ) )
	end
	
	for k, v in pairs( pl:GetBodyGroups( ) ) do
		legEnt:SetBodygroup( v.id, pl:GetBodygroup( v.id ) )
	end
	
	if ( ( self.nextMatSet or 0 ) <= CurTime( ) ) then
		for k, v in pairs( pl:GetMaterials( ) ) do
			legEnt:SetSubMaterial( k - 1, pl:GetSubMaterial( k - 1 ) )
		end
		
		self.nextMatSet = CurTime( ) + 10
	end
	
	self.velocity = pl:GetVelocity( ):Length2D( )
	self.playBackRate = 1
	
	if ( self.velocity > 0.5 ) then
		self.playBackRate = speed < 0.001 and 0.01 or math.Clamp( self.velocity / speed, 0.01, 10 )
	end

	legEnt:SetPlaybackRate( self.playBackRate )
	self.sequence = pl:GetSequence( )
	
	if ( legEnt.Anim != self.sequence ) then
		legEnt.Anim = self.sequence
		legEnt:ResetSequence( self.sequence )
	end
	
	legEnt:FrameAdvance( curTime - legEnt.lastTick )
	legEnt.lastTick = curTime
	self.breathScale = 0.5
	
	if ( self.nextBreath <= curTime ) then
		self.nextBreath = curTime + 1.95 / self.breathScale
		self.legEnt:SetPoseParameter( "breathing", self.breathScale )
	end
	
	legEnt:SetPoseParameter( "move_x", ( pl:GetPoseParameter( "move_x" ) * 2 ) - 1 )
	legEnt:SetPoseParameter( "move_y", ( pl:GetPoseParameter( "move_y" ) * 2 ) - 1 )
	legEnt:SetPoseParameter( "move_yaw", ( pl:GetPoseParameter( "move_yaw" ) * 360 ) - 180 )
	legEnt:SetPoseParameter( "body_yaw", ( pl:GetPoseParameter( "body_yaw" ) * 180 ) - 90 )
	legEnt:SetPoseParameter( "spine_yaw",( pl:GetPoseParameter( "spine_yaw" ) * 180 ) - 90 )
	
	if ( pl:InVehicle( ) ) then
		legEnt:SetColor( color_transparent )
		legEnt:SetPoseParameter( "vehicle_steer", ( pl:GetVehicle( ):GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 )
	end
end

function PLUGIN:RenderScreenspaceEffects( )
	local pl = catherine.pl
	
	cam.Start3D( EyePos( ), EyeAngles( ) )
		if ( pl:ShouldDrawLegs( ) ) then
			self.renderPos = pl:GetPos( )
			
			if ( pl:InVehicle( ) ) then
				self.renderAngle = pl:GetVehicle( ):GetAngles( )
				self.renderAngle:RotateAroundAxis( self.renderAngle:Up( ), 90 )
			else
				self.biaisAngles = pl:EyeAngles( )
				self.renderAngle = Angle( 0, self.biaisAngles.y, 0 )
				self.radAngle = math.rad( self.biaisAngles.y )
				self.forwardOffset = -20
				self.renderPos.x = self.renderPos.x + math.cos( self.radAngle ) * self.forwardOffset
				self.renderPos.y = self.renderPos.y + math.sin( self.radAngle ) * self.forwardOffset
				
				if ( pl:GetGroundEntity( ) == NULL ) then
					self.renderPos.z = self.renderPos.z + 8
					
					if ( pl:KeyDown( IN_DUCK ) ) then
						self.renderPos.z = self.renderPos.z - 28
					end
				end
			end
			
			self.renderColor = pl:GetColor( )
			
			local enabled = render.EnableClipping( true )
			local legEnt = self.legEnt
			
			render.PushCustomClipPlane( self.clipVector, self.clipVector:Dot( EyePos( ) ) )
			render.SetColorModulation( self.renderColor.r / 255, self.renderColor.g / 255, self.renderColor.b / 255 )
			render.SetBlend( self.renderColor.a / 255 )
			
			legEnt:SetRenderOrigin( self.renderPos )
			legEnt:SetRenderAngles( self.renderAngle )
			legEnt:SetupBones( )
			legEnt:DrawModel( )
			legEnt:SetRenderOrigin( )
			legEnt:SetRenderAngles( )
			
			render.SetBlend( 1 )
			render.SetColorModulation( 1, 1, 1 )
			render.PopCustomClipPlane( )
			render.EnableClipping( enabled )
		end
	cam.End3D( )
end

catherine.option.Register( "CONVAR_LEGS", "cat_convar_legs", "^Option_Str_LEG_Name", "^Option_Str_LEG_Desc", "^Option_Category_01", CAT_OPTION_SWITCH )