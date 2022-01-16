--[[
Description: Rename items to folder and track name item position number in the track
Author: Mathieu CONAN   
Version: 0.0.1
Changelog: Initial release
Link: Github repository https://github.com/MathieuCGit/MC_VariousScripts
About: This script aims to rename item with folder name (if track is in folder) - track name - item position in the track
    # WARNING : it's a persistent script, continuously running in background.
--]]

--
--[[ USER OPTIONS ]]
--
SHOW_PARENT_FOLDER= 0
SHOW_TRACK_NAME = 1
SHOW_ITEM_NBR = 1

--
--[[ FUNCTIONS ]]
--
	---Debug function - display messages in reaper console
	--@tparam string String aims to be displayed in the reaper console
	function dbg(String)

	  reaper.ShowConsoleMsg(tostring(String).."\n")
	end

	-- Allow us to make the script toggled (on/off) in the action list. This way it can be use easier in toolbars
	-- this function is a total and unshamed copy/paste from awesome Lokasenna - Track selection follows item selection
	-- https://raw.githubusercontent.com/ReaTeam/ReaScripts/master/Items Properties/Lokasenna_Track selection follows item selection.lua
	(function()
		local _, _, sectionId, cmdId = reaper.get_action_context()

		if sectionId ~= -1 then
			--if script is running
			reaper.SetToggleCommandState(sectionId, cmdId, 1)--set toggle state to On in action list
			reaper.RefreshToolbar2(sectionId, cmdId) --set toggle State to On in toolbar

				reaper.atexit(function()
				--before script totaly stop
				reaper.SetToggleCommandState(sectionId, cmdId, 0) --set toggle state to Off in action list
				reaper.RefreshToolbar2(sectionId, cmdId)--set toggle State to Off in toolbar
				end)
		end
	end)()
	
--
--[[ CORE ]]--
--
function Main()
	
	for i=0,  reaper.CountTracks(0)-1 do --iterate throught project tracks
	
		track = reaper.GetTrack(0, i) --get current track info
		nbrOfItemsOnTrack =  reaper.CountTrackMediaItems( track ) --get nbre of item for current track

		if SHOW_PARENT_FOLDER == 1 then
			-- we get the parent folder track name
			parentTrack = reaper.GetParentTrack( track )
			if parentTrack ~= nil then
			--If track has a parent folder
				_, parentFolderName = reaper.GetSetMediaTrackInfo_String(parentTrack, "P_NAME", "", false)-- get parent track name	
			else		
				parentFolderName=""
			end
		else		
			parentFolderName=""
		end
		
		if SHOW_TRACK_NAME == 1 then
			_, trackName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false) --get current track name
			if trackName == "" then 
			--if track name is empty we use track number instead
				trackName = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") --get current track number 
				trackName = math.floor(trackName) -- change float value to integer
			end
		else
			trackName=""
		end
				
		finalName = parentFolderName.."_"..trackName
		
		
		if nbrOfItemsOnTrack > 0 then
			--rename each item only with track name
			for j=0, nbrOfItemsOnTrack-1 do
				item =  reaper.GetTrackMediaItem(track,j)--get each item on the track
				take = reaper.GetActiveTake(item) --get the active take for eah item
				if take ~= nil then	
					if SHOW_ITEM_NBR == 1 then
					_, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", finalName..j+1, true )--we rename it only with trackName
					else
					_, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", finalName, true )--we rename it only with trackName
					end
				end	
			end		
		end
	end

	
reaper.defer(Main)
end


--
--[[ EXECUTION ]]--
--

-- clear console debug
reaper.ShowConsoleMsg("")

reaper.PreventUIRefresh(1)

-- execute script core
Main()
 
-- update arrange view UI
reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)