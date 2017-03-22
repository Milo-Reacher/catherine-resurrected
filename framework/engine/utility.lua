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

catherine.util = catherine.util or { }

function catherine.util.Print( col, val )
	MsgC( col or Color( 255, 255, 255 ), "[CAT] " .. val .. "\n" )
end

function catherine.util.Include( dir, typ )
	dir = dir:lower( )
	
	if ( SERVER and ( typ == "SERVER" or dir:find( "sv_" ) ) ) then
		include( dir )
	elseif ( typ == "CLIENT" or dir:find( "cl_" ) ) then
		AddCSLuaFile( dir )
		
		if ( CLIENT ) then
			include( dir )
		end
	elseif ( typ == "SHARED" or dir:find( "sh_" ) ) then
		AddCSLuaFile( dir )
		include( dir )
	end
end

function catherine.util.IncludeInDir( dir, prefix )
	local dir3 = ( prefix or "catherine/framework/" ) .. dir
	
	for k, v in pairs( file.Find( ( prefix or "catherine/framework/" ) .. dir .. "/*.lua", "LUA" ) ) do
		catherine.util.Include( dir3 .. "/" .. v )
	end
end

function catherine.util.CalcDistanceByPos( loc, target )
	if ( !IsValid( loc ) or !IsValid( target ) ) then return 0 end
	
	return loc:GetPos( ):Distance( target:GetPos( ) )
end

function catherine.util.IsSteamID( steamID )
	return steamID:match( "STEAM_[0-5]:[0-9]:[0-9]+" )
end

function catherine.util.FindPlayerByName( name )
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( catherine.util.CheckStringMatch( v:Name( ), name ) ) then
			return v
		end
	end
end

function catherine.util.FindPlayerByStuff( use, str )
	for k, v in pairs( player.GetAllByLoaded( ) ) do
		if ( catherine.util.CheckStringMatch( v[ use ]( v ), str ) ) then
			return v
		end
	end
end

function catherine.util.CheckStringMatch( one, two )
	if ( one and two ) then
		local one2, two2 = one:lower( ), two:lower( )
		
		if ( one == two ) then return true end
		if ( one2 == two2 ) then return true end
		
		if ( one:find( two ) ) then return true end
		if ( one2:find( two2 ) ) then return true end
	end
	
	return false
end

function catherine.util.GetUniqueName( name )
	return name:sub( 4, -5 )
end

function catherine.util.IsStuckPos( pos )
	return util.TraceLine( {
		start = pos,
		endpos = pos
	} ).StartSolid
end

function catherine.util.GetRealTime( )
	local one = os.date( "*t" )
	
	return one.year .. "-" .. one.month .. "-" .. one.day .. " | " .. os.date( "%p" ) .. " " .. os.date( "%I" ) .. ":" .. os.date( "%M" )
end

function catherine.util.GetChatTimeStamp( )
	local hour = tonumber( os.date( "%H" ) )
	
	return os.date( "%p" ) .. " " .. ( hour > 12 and hour - 12 or hour ) .. ":" .. os.date( "%M" )
end

function catherine.util.GetAdmins( isSuperAdmin )
	local players = { }
	
	if ( isSuperAdmin ) then
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( !v:IsSuperAdmin( ) ) then continue end
			
			players[ #players + 1 ] = v
		end
	else
		for k, v in pairs( player.GetAllByLoaded( ) ) do
			if ( !v:IsAdmin( ) ) then continue end
			
			players[ #players + 1 ] = v
		end
	end
	
	return players
end

function catherine.util.FolderDirectoryTranslate( dir )
	if ( dir:sub( 1, 1 ) != "/" ) then
		dir = "/" .. dir
	end
	
	local ex = string.Explode( "/", dir )
	
	for k, v in pairs( ex ) do
		if ( v != "" ) then continue end
		
		table.remove( ex, k )
	end
	
	return ex
end

function catherine.util.GetItemDropPos( pl )
	local tr = pl:GetEyeTraceNoCursor( )
	
	if ( pl:GetShootPos( ):Distance( tr.HitPos ) < 100 ) then
		return tr.HitPos
	end
	
	return pl:GetShootPos( ) + pl:GetAimVector( ) * 100
end

function catherine.util.RemoveEntityByClass( class )
	for k, v in pairs( ents.FindByClass( class ) ) do
		SafeRemoveEntity( v )
	end
end

function catherine.util.IsInBox( ent, minVector, maxVector, ignoreZPos )
	local pos = ent:GetPos( )
	
	if ( ignoreZPos ) then
		if ( ( pos.x >= math.min( minVector.x, maxVector.x ) and pos.x <= math.max( minVector.x, maxVector.x ) )
		and ( pos.y >= math.min( minVector.y, maxVector.y ) and pos.y <= math.max( minVector.y, maxVector.y ) ) ) then
			return true
		end
	else
		if ( ( pos.x >= math.min( minVector.x, maxVector.x ) and pos.x <= math.max( minVector.x, maxVector.x ) )
		and ( pos.y >= math.min( minVector.y, maxVector.y ) and pos.y <= math.max( minVector.y, maxVector.y ) )
		and ( pos.z >= math.min( minVector.z, maxVector.z ) and pos.z <= math.max( minVector.z, maxVector.z ) ) ) then
			return true
		end
	end
end

function catherine.util.GetDoorPartner( ent )
	for k, v in pairs( ents.FindInSphere( ent:GetPos( ), 128 ) ) do
		if ( v:GetClass( ) == "prop_door_rotating" and ent:GetModel( ) == v:GetModel( ) and ent != v ) then
			return v
		end
	end
end

function catherine.util.GetDoorPartners( ent )
	local partners = { }
	
	for k, v in pairs( ents.FindInSphere( ent:GetPos( ), 128 ) ) do
		if ( v:GetClass( ) == "prop_door_rotating" and ent:GetModel( ) == v:GetModel( ) and ent != v ) then
			partners[ #partners + 1 ] = v
		end
	end
	
	return partners
end

local holdTypes = {
	weapon_physgun = "smg",
	weapon_physcannon = "smg",
	weapon_stunstick = "melee",
	weapon_crowbar = "melee",
	weapon_stunstick = "melee",
	weapon_357 = "pistol",
	weapon_pistol = "pistol",
	weapon_smg1 = "smg",
	weapon_ar2 = "smg",
	weapon_crossbow = "smg",
	weapon_shotgun = "shotgun",
	weapon_frag = "grenade",
	weapon_slam = "grenade",
	weapon_rpg = "shotgun",
	weapon_bugbait = "melee",
	weapon_annabelle = "shotgun",
	gmod_tool = "pistol"
}

local translateHoldType = {
	melee2 = "melee",
	fist = "melee",
	knife = "melee",
	ar2 = "smg",
	physgun = "smg",
	crossbow = "smg",
	slam = "grenade",
	passive = "normal",
	rpg = "shotgun"
}

function catherine.util.GetHoldType( wep )
	local holdType = holdTypes[ wep:GetClass( ) ]
	
	if ( holdType ) then
		return holdType
	elseif ( wep.HoldType ) then
		return translateHoldType[ wep.HoldType ] or wep.HoldType
	else
		return "normal"
	end
end

function catherine.util.GetDivideTextData( text, width )
	local line = ""
	local wrapData = { }
	local ex = string.Explode( "%s", text, true )
	local topW = 0
	local tw = text:utf8len( )
	
	if ( tw <= width ) then
		return { ( text:gsub( "%s", " " ) ) }, tw
	end
	
	for i = 1, #ex do
		line = line .. " " .. ex[ i ]
		tw = line:utf8len( )
		
		if ( tw > width ) then
			wrapData[ #wrapData + 1 ] = line
			line = ""
		end
	end
	
	if ( line != "" ) then
		wrapData[ #wrapData + 1 ] = line
	end
	
	return wrapData
end

catherine.util.Include( "catherine/framework/engine/external/sh_netstream2.lua" )
catherine.util.Include( "catherine/framework/engine/external/sh_pon.lua" )
catherine.util.Include( "catherine/framework/engine/external/sh_utf8.lua" )

if ( SERVER ) then
	catherine.util.receiver = catherine.util.receiver or { str = { }, qry = { } }
	
	function catherine.util.Notify( pl, message, time )
		netstream.Start( pl, "catherine.util.Notify", {
			message,
			time
		} )
	end
	
	function catherine.util.NotifyAll( message, time )
		netstream.Start( player.GetAllByLoaded( ), "catherine.util.Notify", {
			message,
			time
		} )
	end
	
	function catherine.util.NotifyAllLang( key, ... )
		netstream.Start( player.GetAllByLoaded( ), "catherine.util.NotifyAllLang", {
			key,
			{ ... }
		} )
	end
	
	function catherine.util.NotifyLang( pl, key, ... )
		netstream.Start( pl, "catherine.util.NotifyLang", {
			key,
			{ ... }
		} )
	end
	
	function catherine.util.StuffLanguage( pl, key, ... )
		key = key or "^Basic_LangKeyError"
		
		return key:Left( 1 ) == "^" and LANG( pl, key:sub( 2 ), ... ) or key
	end
	
	function catherine.util.GetForceClientConVar( pl, convarID, func )
		netstream.Start( pl, "catherine.util.GetForceClientConVar", convarID )
		
		netstream.Hook( "catherine.util.GetForceClientConVarReceive", function( pl, data )
			func( data )
		end )
	end
	
	function catherine.util.ProgressBar( pl, message, time, func )
		local timerID = pl:SteamID( )
		
		timer.Remove( timerID )
		
		if ( message != false and func ) then
			timer.Create( timerID, time, 1, function( )
				if ( IsValid( pl ) ) then
					func( pl )
				end
			end )
		end
		
		netstream.Start( pl, "catherine.util.ProgressBar", {
			message,
			time
		} )
	end
	
	function catherine.util.TopNotify( pl, message )
		netstream.Start( pl, "catherine.util.TopNotify", message )
	end
	
	function catherine.util.PlayAdvanceSound( pl, uniqueID, dir, volume )
		pl.CAT_soundAdvPlaying = pl.CAT_soundAdvPlaying or { }
		
		if ( !pl.CAT_soundAdvPlaying[ uniqueID ] or pl.CAT_soundAdvPlaying[ uniqueID ] != dir ) then
			pl.CAT_soundAdvPlaying[ uniqueID ] = dir
			
			netstream.Start( pl, "catherine.util.PlayAdvanceSound", {
				uniqueID,
				dir,
				volume
			} )
		end
	end
	
	function catherine.util.PlaySimpleSound( pl, dir )
		netstream.Start( pl, "catherine.util.PlaySimpleSound", dir )
	end
	
	function catherine.util.StopAdvanceSound( pl, uniqueID, fadeOut )
		if ( pl.CAT_soundAdvPlaying and pl.CAT_soundAdvPlaying[ uniqueID ] ) then
			pl.CAT_soundAdvPlaying[ uniqueID ] = nil
			
			netstream.Start( pl, "catherine.util.StopAdvanceSound", {
				uniqueID,
				fadeOut
			} )
		end
	end
	
	local resourceBlockFolders = {
		".svn",
		".git"
	}
	
	function catherine.util.AddResourceInFolder( dir )
		local files, folders = file.Find( dir .. "/*", "GAME" )
		
		for k, v in pairs( folders ) do
			if ( table.HasValue( resourceBlockFolders, v ) ) then continue end
			
			catherine.util.AddResourceInFolder( dir .. "/" .. v )
		end
		
		for k, v in pairs( files ) do
			resource.AddFile( dir .. "/" .. v )
		end
	end
	
	function catherine.util.ForceDoorOpen( ent, lifeTime, vel, ignorePartnerDoor )
		if ( !ent:IsDoor( ) ) then return end
		
		lifeTime = lifeTime or 150
		vel = vel or VectorRand( ) * 120
		
		if ( IsValid( ent.CAT_doorDummy ) ) then
			ent.CAT_doorDummy:Remove( )
		end
		
		local partner = catherine.util.GetDoorPartner( ent )
		
		if ( IsValid( partner ) and !ignorePartnerDoor ) then
			catherine.util.ForceDoorOpen( partner, lifeTime, vel, true )
		end
		
		local col = ent:GetColor( )
		
		local dummyEnt = ents.Create( "prop_physics" )
		dummyEnt:SetPos( ent:GetPos( ) )
		dummyEnt:SetAngles( ent:GetAngles( ) )
		dummyEnt:SetModel( ent:GetModel( ) )
		dummyEnt:SetColor( col )
		dummyEnt:SetMaterial( ent:GetMaterial( ) )
		dummyEnt:SetSkin( ent:GetSkin( ) or 0 )
		dummyEnt:SetRenderMode( RENDERMODE_TRANSALPHA )
		dummyEnt:SetOwner( ent )
		dummyEnt:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		dummyEnt:Spawn( )
		dummyEnt:CallOnRemove( "RecoverDoor", function( )
			if ( !IsValid( ent ) ) then return end
			
			ent:SetNotSolid( false )
			ent:SetNoDraw( false )
			ent:DrawShadow( true )
			ent.CAT_ignoreUse = nil
			
			for k, v in pairs( ents.GetAll( ) ) do
				if ( v:GetParent( ) != ent ) then continue end
				
				v:SetNotSolid( false )
				v:SetNoDraw( false )
			end
		end )
		
		ent:Fire( "UnLock" )
		ent:Fire( "Open" )
		ent:SetNotSolid( true )
		ent:SetNoDraw( true )
		ent:DrawShadow( false )
		ent:DeleteOnRemove( dummyEnt )
		ent.CAT_doorDummy = dummyEnt
		ent.CAT_ignoreUse = true
		
		for k, v in pairs( ent:GetBodyGroups( ) ) do
			dummyEnt:SetBodygroup( v.id, ent:GetBodygroup( v.id ) )
		end
		
		for k, v in pairs( ents.GetAll( ) ) do
			if ( v:GetParent( ) != ent ) then continue end
			
			v:SetNotSolid( true )
			v:SetNoDraw( true )
		end
		
		local physObject = ent:GetPhysicsObject( )
		
		if ( IsValid( physObject ) ) then
			physObject:SetVelocity( vel )
		end
		
		local timerID = "Catherine.timer.DoorForceOpen." .. ent:EntIndex( )
		local timerID2 = "Catherine.timer.DoorRestore." .. ent:EntIndex( )
		
		timer.Create( timerID, 1, 0, function( )
			if ( IsValid( ent ) and IsValid( ent.CAT_doorDummy ) ) then
				if ( !ent.CAT_isDoorOpened ) then
					ent:Fire( "Open" )
					ent.CAT_isDoorOpened = true
				end
			else
				timer.Remove( timerID )
			end
		end )
		
		timer.Create( timerID2, lifeTime, 1, function( )
			if ( !IsValid( ent ) or !IsValid( ent.CAT_doorDummy ) ) then
				return
			end
			
			local timerID3 = "Catherine.timer.DoorFade." .. ent:EntIndex( )
			local alpha = col.a
			
			timer.Create( timerID3, 0.1, col.a, function( )
				if ( IsValid( dummyEnt ) ) then
					alpha = alpha - 1
					dummyEnt:SetColor( Color( col.r, col.g, col.b, alpha ) )
					
					if ( alpha <= 0 ) then
						dummyEnt:Remove( )
					end
				else
					timer.Remove( timerID2 )
					timer.Remove( timerID3 )
				end
			end )
		end )
		
		return dummyEnt
	end
	
	function catherine.util.StartMotionBlur( pl, addAlpha, drawAlpha, delay )
		netstream.Start( pl, "catherine.util.StartMotionBlur", {
			addAlpha,
			drawAlpha,
			delay
		} )
	end
	
	function catherine.util.StopMotionBlur( pl, fadeTime )
		netstream.Start( pl, "catherine.util.StopMotionBlur", fadeTime )
	end
	
	function catherine.util.SendDermaMessage( pl, msg, okStr, sound )
		netstream.Start( pl, "catherine.util.SendDermaMessage", {
			msg,
			okStr or false,
			sound
		} )
	end
	
	function catherine.util.StringReceiver( pl, id, msg, defV, func )
		local steamID = pl:SteamID( )
		
		catherine.util.receiver.str[ steamID ] = catherine.util.receiver.str[ steamID ] or { }
		catherine.util.receiver.str[ steamID ][ id ] = func
		
		netstream.Start( pl, "catherine.util.StringReceiver", {
			id,
			msg,
			defV or ""
		} )
	end
	
	function catherine.util.QueryReceiver( pl, id, msg, func )
		local steamID = pl:SteamID( )
		
		catherine.util.receiver.qry[ steamID ] = catherine.util.receiver.qry[ steamID ] or { }
		catherine.util.receiver.qry[ steamID ][ id ] = func
		
		netstream.Start( pl, "catherine.util.QueryReceiver", {
			id,
			msg
		} )
	end
	
	function catherine.util.ScreenColorEffect( pl, col, time, fadeTime )
		netstream.Start( pl, "catherine.util.ScreenColorEffect", {
			col or Color( 255, 255, 255 ),
			time,
			fadeTime
		} )
	end
	
	netstream.Hook( "catherine.util.StringReceiverReceive", function( pl, data )
		local id = data[ 1 ]
		local steamID = pl:SteamID( )
		local rec = catherine.util.receiver.str
		
		if ( !rec[ steamID ] or !rec[ steamID ][ id ] ) then return end
		
		rec[ steamID ][ id ]( pl, data[ 2 ] )
		catherine.util.receiver.str[ steamID ][ id ] = nil
	end )
	
	netstream.Hook( "catherine.util.QueryReceiverReceive", function( pl, data )
		local id = data[ 1 ]
		local steamID = pl:SteamID( )
		local rec = catherine.util.receiver.qry
		
		if ( !rec[ steamID ] or !rec[ steamID ][ id ] ) then return end
		
		rec[ steamID ][ id ]( pl, data[ 2 ] )
		catherine.util.receiver.qry[ steamID ][ id ] = nil
	end )
else
	catherine.util.materials = catherine.util.materials or { }
	catherine.util.advSounds = catherine.util.advSounds or { }
	catherine.util.motionBlur = catherine.util.motionBlur or nil
	catherine.util.dermaMenuTitle = catherine.util.dermaMenuTitle or nil
	local blurMat = Material( "pp/blurscreen" )
	
	netstream.Hook( "catherine.util.SendDermaMessage", function( data )
		Derma_Message( data[ 1 ], nil, data[ 2 ] or LANG( "Basic_UI_OK" ), data[ 3 ] )
	end )
	
	netstream.Hook( "catherine.util.GetForceClientConVar", function( data )
		netstream.Start( "catherine.util.GetForceClientConVarReceive", GetConVarString( data ) )
	end )
	
	netstream.Hook( "catherine.util.StringReceiver", function( data )
		Derma_StringRequest( "", catherine.util.StuffLanguage( data[ 2 ] ), data[ 3 ] or "", function( val )
				netstream.Start( "catherine.util.StringReceiverReceive", {
					data[ 1 ],
					val
				} )
			end, function( ) end, LANG( "Basic_UI_OK" ), LANG( "Basic_UI_NO" )
		)
	end )
	
	netstream.Hook( "catherine.util.QueryReceiver", function( data )
		Derma_Query( catherine.util.StuffLanguage( data[ 2 ] ), "", LANG( "Basic_UI_OK" ), function( )
				netstream.Start( "catherine.util.QueryReceiverReceive", {
					data[ 1 ],
					true
				} )
			end, LANG( "Basic_UI_NO" ), function( ) 
				netstream.Start( "catherine.util.QueryReceiverReceive", {
					data[ 1 ],
					false
				} )
			end
		)
	end )
	
	netstream.Hook( "catherine.util.StartMotionBlur", function( data )
		catherine.util.motionBlur = {
			status = true,
			fadeTime = 0.1,
			addAlpha = data[ 1 ],
			drawAlpha = data[ 2 ],
			delay = data[ 3 ]
		}
	end )
	
	netstream.Hook( "catherine.util.StopMotionBlur", function( data )
		local motionBlurData = catherine.util.motionBlur
		
		if ( motionBlurData ) then
			motionBlurData = {
				status = false,
				fadeTime = data or 0.1,
				addAlpha = motionBlurData.addAlpha,
				drawAlpha = motionBlurData.drawAlpha,
				delay = motionBlurData.delay
			}
			
			catherine.util.motionBlur = motionBlurData
		end
	end )
	
	netstream.Hook( "catherine.util.ScreenColorEffect", function( data )
		local col = data[ 1 ]
		local time = CurTime( ) + ( data[ 2 ] or 0.1 )
		local fadeTime = data[ 3 ] or 0.03
		local a = 255
		
		hook.Remove( "HUDPaint", "catherine.util.ScreenColorEffect" )
		hook.Add( "HUDPaint", "catherine.util.ScreenColorEffect", function( )
			if ( time <= CurTime( ) ) then
				a = Lerp( fadeTime, a, 0 )
				
				if ( math.Round( a ) <= 0 ) then
					hook.Remove( "HUDPaint", "catherine.util.ScreenColorEffect" )
					return
				end
			end
			
			draw.RoundedBox( 0, 0, 0, ScrW( ), ScrH( ), Color( col.r, col.g, col.b, a ) )
		end )
	end )
	
	netstream.Hook( "catherine.util.PlayAdvanceSound", function( data )
		if ( !IsValid( catherine.pl ) ) then return end
		local uniqueID = data[ 1 ]
		local dir = data[ 2 ]
		local volume = data[ 3 ]
		
		if ( catherine.util.advSounds[ uniqueID ] ) then
			catherine.util.advSounds[ uniqueID ]:Stop( )
		end
		
		local soundObj = CreateSound( catherine.pl, dir )
		soundObj:PlayEx( volume, 100 )
		
		catherine.util.advSounds[ uniqueID ] = soundObj
	end )
	
	netstream.Hook( "catherine.util.PlaySimpleSound", function( data )
		surface.PlaySound( data )
	end )
	
	netstream.Hook( "catherine.util.StopAdvanceSound", function( data )
		if ( !IsValid( catherine.pl ) ) then return end
		local uniqueID = data[ 1 ]
		local fadeOut = data[ 2 ]
		local soundObj = catherine.util.advSounds[ uniqueID ]
		
		if ( soundObj ) then
			if ( fadeOut == 0 ) then
				soundObj:Stop( )
			else
				soundObj:FadeOut( fadeOut )
			end
			
			catherine.util.advSounds[ uniqueID ] = nil
		end
	end )
	
	netstream.Hook( "catherine.util.Notify", function( data )
		catherine.notify.Add( data[ 1 ], data[ 2 ] )
	end )
	
	netstream.Hook( "catherine.util.NotifyLang", function( data )
		catherine.notify.Add( LANG( data[ 1 ], unpack( data[ 2 ] ) ) )
	end )
	
	netstream.Hook( "catherine.util.NotifyAllLang", function( data )
		catherine.notify.Add( LANG( data[ 1 ], unpack( data[ 2 ] ) ) )
	end )
	
	netstream.Hook( "catherine.util.ProgressBar", function( data )
		if ( data[ 1 ] == false ) then
			catherine.hud.progressBar = nil
			return
		end
		
		catherine.hud.ProgressBarAdd( catherine.util.StuffLanguage( data[ 1 ] ), data[ 2 ] )
	end )
	
	netstream.Hook( "catherine.util.TopNotify", function( data )
		if ( data == false ) then
			catherine.hud.topNotify = nil
			return
		end
		
		catherine.hud.TopNotifyAdd( data )
	end )
	
	function catherine.util.PlayButtonSound( typ )
	
	end
	
	function catherine.util.StuffLanguage( key, ... )
		key = key or "^Basic_LangKeyError"
		
		return key:Left( 1 ) == "^" and LANG( key:sub( 2 ), ... ) or key
	end
	
	function catherine.util.DrawCoolText( message, font, x, y, col, xA, yA, backgroundCol, backgroundBor )
		if ( !message or !font or !x or !y ) then return end
		backgroundBor = backgroundBor or 5
		
		surface.SetFont( font )
		local tw, th = surface.GetTextSize( message )
		
		draw.RoundedBox( 0, x - ( tw / 2 ) - backgroundBor, y - ( th / 2 ) - backgroundBor, tw + ( backgroundBor * 2 ), th + ( backgroundBor * 2 ), backgroundCol or Color( 50, 50, 50, 255 ) )
		draw.SimpleText( message, font, x, y, col or Color( 255, 255, 255, 255 ), xA or 1, yA or 1 )
	end
	
	function catherine.util.GetAlphaFromDistance( base, x, max )
		return ( 1 - ( x:Distance( base ) / max ) ) * 255
	end
	
	function catherine.util.RegisterMaterial( key, matDir, correction )
		catherine.util.materials[ key ] = catherine.util.materials[ key ] or Material( matDir, correction )
		
		return catherine.util.materials[ key ]
	end
	
	function catherine.util.SetDermaMenuTitle( menuPanel, title )	
		if ( !menuPanel or !title ) then
			catherine.util.dermaMenuTitle = nil
			return
		end
		
		catherine.util.dermaMenuTitle = {
			menuPanel = menuPanel,
			title = title
		}
	end
	
	function catherine.util.BlurDraw( x, y, w, h, amount )
		surface.SetMaterial( blurMat )
		surface.SetDrawColor( 255, 255, 255 )
		
		for i = -0.2, 1, 0.2 do
			blurMat:SetFloat( "$blur", i * ( amount or 5 ) )
			blurMat:Recompute( )
			render.UpdateScreenEffectTexture( )
			surface.DrawTexturedRectUV( x, y, w, h, x / ScrW( ), y / ScrH( ), ( x + w ) / ScrW( ), ( y + h ) / ScrH( ) )
		end
	end
	
	function catherine.util.GetWrapTextData( text, width, font )
		font = font or "catherine_normal15"
		surface.SetFont( font )
		
		local line = ""
		local wrapData = { }
		local tw = surface.GetTextSize( text )
		local ex = string.Explode( "%s", text, true )
		local topW = 0
		
		if ( tw <= width ) then
			return { ( text:gsub( "%s", " " ) ) }, tw
		end
		
		for i = 1, #ex do
			line = line .. " " .. ex[ i ]
			tw = surface.GetTextSize( line )
			
			if ( tw > width ) then
				wrapData[ #wrapData + 1 ] = line
				line = ""
				
				topW = math.max( topW, tw )
			end
		end
		
		if ( line != "" ) then
			wrapData[ #wrapData + 1 ] = line
		end
		
		return wrapData, topW
	end
end