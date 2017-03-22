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

catherine.question = catherine.question or { }
catherine.question.lists = { }

function catherine.question.Register( title, answerList, answerIndex )
	catherine.question.lists[ #catherine.question.lists + 1 ] = {
		title = title,
		answerList = answerList,
		answerIndex = answerIndex
	}
end

function catherine.question.GetAll( )
	return catherine.question.lists
end

function catherine.question.FindByIndex( index )
	return catherine.question.lists[ index ]
end

if ( SERVER ) then
	catherine.question.descriptiveBuffer = catherine.question.descriptiveBuffer or { }
	
	function catherine.question.Start( pl )
		netstream.Start( pl, "catherine.question.Start" )
	end
	
	function catherine.question.Check( pl, answers )
		local questionTable = catherine.question.GetAll( )
		
		if ( #questionTable == 0 ) then
			catherine.question.SetQuestionComplete( pl, "1" )
			netstream.Start( pl, "catherine.question.CloseMenu" )
			
			return
		end
		
		if ( #answers != #questionTable ) then
			pl:Kick( LANG( pl, "Question_KickMessage" ) )
			
			return
		end
		
		local answerIndexes = { }
		
		for k, v in pairs( questionTable ) do
			answerIndexes[ k ] = v.answerIndex
		end
		
		for k, v in pairs( answers ) do
			if ( v != answerIndexes[ k ] ) then
				pl:Kick( LANG( pl, "Question_KickMessage" ) )
				
				return
			end
		end
		
		catherine.question.SetQuestionComplete( pl, "1" )
		netstream.Start( pl, "catherine.question.CloseMenu" )
	end
	
	function catherine.question.SetQuestionComplete( pl, val )
		catherine.catData.SetVar( pl, "question", val, false, true )
	end
	
	function catherine.question.IsQuestionComplete( pl )
		return catherine.catData.GetVar( pl, "question" ) == "1"
	end
	
	netstream.Hook( "catherine.question.Check", function( pl, data )
		catherine.question.Check( pl, data )
	end )
else
	netstream.Hook( "catherine.question.CloseMenu", function( data )
		if ( IsValid( catherine.vgui.question ) ) then
			catherine.vgui.question:Remove( )
		end
		
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:SetVisible( true )
		end
	end )
	
	function catherine.question.Start( )
		if ( IsValid( catherine.vgui.question ) ) then
			catherine.vgui.question:Remove( )
		end
		
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:Remove( )
		end
		
		catherine.vgui.character = vgui.Create( "catherine.vgui.character" )
		catherine.vgui.question = vgui.Create( "catherine.vgui.question" )
		
		if ( IsValid( catherine.vgui.character ) ) then
			catherine.vgui.character:SetVisible( false )
		end
	end
	
	function catherine.question.CanQuestion( )
		if ( !catherine.configs.enableQuiz or catherine.catData.GetVar( "question" ) == "1" or #catherine.question.GetAll( ) == 0 ) then
			return false
		else
			return true
		end
	end
end