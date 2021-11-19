--[[
   * @description ReaScript Name: Draw separator on folder track - aka A la Logic X
   * Lua script for Cockos REAPER
   * @about This script aims to reproduce the folder separation in a way Logic X does it
   * @author: Mathieu CONAN
   * @author URI: https://forum.cockos.com/member.php?u=153781
   * Licence: GPL v3
   * REAPER: 6.0
   * @version 0.1
   * Extensions: None   
--]]

--[[
 * @Changelog:
 * v1.0 (2021-11-20)
   + Initial Release
--]]

--
--[[ USER CUSTOMIZATION ]]--
--

-- this MUST be AT LEAST 2 pixels higher than the size defined in Preferences > Apparence > Media > "Hide labels for items when item take lane height is less than". 
--You also have to uncheck "draw labels above items, rather than within items"
-- Default value is 28 but I got better result with 20pixels.
-- Default 6 and dafault 5 theme TRACK_HEIGHT=25. Also work with Jane, Funktion, 
-- Other tested themes and values :
-- iLogic V2 = 28
-- iLogic V3 = 24
-- Flat Madness and CubeXD= 22
TRACK_HEIGHT=22 --height in pixel

TRACK_COLOR_SINGLE=0 --do you want all the item folder to get the same color ? Otherwise, default folder track color will be used. Default is 0
TRACK_COLOR={111,121,131} -- use RGB color code. Default is {111,121,131}

TRACK_COLOR_DARKER_STEP = 25 --this is the amount of darkness yo uwant to apply to default track color. 0 means NO darkness. Default is 25

TRACK_LOCK=1 -- 1 means track height is locked, 0 means not locked. Default is 1


--
--[[ Various Functions]]
--

  ---Debug function - display messages in reaper console
  --@tparam string String aims to be displayed in the reaper console
  function Debug(String)
    reaper.ShowConsoleMsg(tostring(String).."\n")
  end

  ---create item on track passd in argument
  function createLogicXItem (track)
      local lastItemTimeEnd=0
      lastItemTimeEnd=getLastItemTimeEnd()
      _,trackName = reaper.GetSetMediaTrackInfo_String( track, "P_NAME",0,0)-- get track name and 
      startTime, endTime = reaper.BR_GetArrangeView(0) --project start and end

      if endTime > lastItemTimeEnd+100 then
      -- if zoom out is too important, some actions like "View: Zoom out project"
      -- fails to adjust size and you have to zoom manually with mouse to get it right
      -- so for now we put a limit based on the lastest item time end + 100...welll...100 is arbitrary...
        endTime=lastItemTimeEnd+50
        endTime=math.floor(endTime+0.5)--we need an integer so we round the float
        startTime=math.floor(startTime+0.5)
        _, _ = reaper.GetSet_ArrangeView2( 0, 1, startTime, endTime )
      end

      -- and create an item which is project lenght
      reaper.AddMediaItemToTrack(track)
      item = reaper.GetTrackMediaItem(track,0)
      reaper.SetMediaItemInfo_Value(item, "D_LENGTH", endTime)
      
      --we need at least one active take to get the track name as a label on items
      nbrOfTake = reaper.CountTakes( item )
      if nbrOfTake == 0 then
      --So if we have no take, we create one
        reaper.AddTakeToMediaItem( item )--add a new take
        take = reaper.GetActiveTake(item) -- make it active   
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", trackName, 1); --rename active take into track name
      end
      
      -- Reaper doesn't prevent an item of being splited even if the item is locked
      -- so this option isn't really useful for now but should be in the future
      -- it only offers a darker color so for now we'd rather to disable it
      -- reaper.SetMediaItemInfo_Value( item, "C_LOCK", TRACK_LOCK )
      
      -- If we want one background color for every items instead of defaut folder color
      if TRACK_COLOR_SINGLE == 1 then
        color=reaper.ColorToNative(TRACK_COLOR[1],TRACK_COLOR[2],TRACK_COLOR[3])|0x1000000
        reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
      end
      
      -- If we want one background color for every items instead of defaut folder color
      if TRACK_COLOR_DARKER_STEP > 0 and TRACK_COLOR_SINGLE == 0 then
        intTrackColor=reaper.GetMediaTrackInfo_Value( track, "I_CUSTOMCOLOR" )
        red, green, blue = reaper.ColorFromNative( intTrackColor )
        -- Debug("red : "..red.." green: "..green.." blue : "..blue)
        
        R=red - TRACK_COLOR_DARKER_STEP 
        if R < 0 then R =255 - R end
        G=green - TRACK_COLOR_DARKER_STEP 
        if G < 0 then G =255 - G end
        B=blue - TRACK_COLOR_DARKER_STEP 
        if B < 0 then B =255 - B end
        
        -- Debug("R : "..R.." G: "..G.." B : "..B)
        color=reaper.ColorToNative(R,G,B)|0x1000000
        reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
      end    
      
      -- we set track height and lock the track height
      reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", TRACK_HEIGHT);
      reaper.SetMediaTrackInfo_Value(track, "B_HEIGHTLOCK",1)
  end
  
    ---remove all items from arrange view. This function is called with reaper.atexit()
  function cleanArrangeView()
    nbrOfTrack =  reaper.CountTracks(0)--nbre of track in the project
  
    for i=0, nbrOfTrack-1 do
    -- for each track
      track =  reaper.GetTrack( 0, i ) --we get info from the current track
      trackFolderDepth = reaper.GetMediaTrackInfo_Value( track, "I_FOLDERDEPTH") --we check if it's a folder or not
      
      if trackFolderDepth > 0.0 then -- if we are on a folder track
        reaper.SetMediaTrackInfo_Value(track, "B_HEIGHTLOCK",0)--unlock track height
        deleteEmptyItemsOnTracks(track)
      end
    end
  end
  
  --- Delete empty item on the track passed
    function deleteEmptyItemsOnTracks(track)
        local nbrOfItems= reaper.GetTrackNumMediaItems(track)--get nbre of items on this track
        
        for j=0, nbrOfItems-1 do --for each item on this track
            item =  reaper.GetTrackMediaItem( track, j )--we get current item info

            if doesItemContainsMidiData(item) == false then 
           -- -- If the item doesn't contain MIDI data (ite means it's an empty item)
                reaper.DeleteTrackMediaItem( track, item ) -- we delete selcted item
            end
        end
        
    end
  
  --- check if an item located on folder track contains MIDI data
  --@tparam item item a Reaper media item
  function doesItemContainsMidiData(item)
    if item ~= nil then --if there is an item
    take=reaper.GetActiveTake(item) -- we get the active take from it
      if take ~= nil then --if there is an active take
      containsMidi = reaper.TakeIsMIDI( take ) -- we check if it contains MIDI data
      --this check is very impotant to prevent removing already existing items with content onto folder tracks
        if containsMidi == false then
          return false
        else
          return true
        end
      end
    end
  end
  
  ---We get the end of the lastest item in the project
    --@tparam track track is a Reaper Track
    --
    --@treturn int lastItemTimeEnd is the time in second of the end of the last item on the timeline
  function getLastItemTimeEnd()
    local lastItemTimeEnd=0
        nbrOfTrack =  reaper.CountTracks(0)--nbre of track in the project
    
    for i=0, nbrOfTrack-1 do
    --for each track
      track =  reaper.GetTrack( 0, i ) --we get info from the current track
      trackFolderDepth = reaper.GetMediaTrackInfo_Value( track, "I_FOLDERDEPTH") --we check if it's a folder or not
      
    if trackFolderDepth <= 0.0 then 
    --if track is NOT a folder (normal=0) or the last track of a folder (negative values)
    nbrOfItems= reaper.GetTrackNumMediaItems(track)--get nbre of items on this track
      
      for j=0, nbrOfItems-1 do
      --for each item 
        item =  reaper.GetTrackMediaItem( track, j )--we get current item info
        itemStart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
        itemLen = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
        itemEnd = itemStart+itemLen
        
        if itemEnd > lastItemTimeEnd then
        --if the selected item ends later than the previous, we use this end time as new project end time
        lastItemTimeEnd = itemEnd
        end

      end
    end
    end
  -- reaper.SetEditCurPos( lastItemTimeEnd, 1, 0 )
  -- Debug( reaper.GetCursorPosition())  
  return lastItemTimeEnd
  end

  --- Allow us to make the script toggled (on/off) in the action list. This way it can be persistant at reaper satartup
  -- this function is a total and unshamed copy/paste from awesome Lokasenna - Track selection follows item selection
  -- https://raw.githubusercontent.com/ReaTeam/ReaScripts/master/Items Properties/Lokasenna_Track selection follows item selection.lua
  (function()
  local _, _, sectionId, cmdId = reaper.get_action_context()

    if sectionId ~= -1 then
    --if script is running
      cleanArrangeView()--clean folder track from every empty items except those with MIDI data
      reaper.SetToggleCommandState(sectionId, cmdId, 1)--set toggle state to On in action list
      reaper.RefreshToolbar2(sectionId, cmdId) --set toggle State to On in toolbar

      reaper.atexit(function()
      --before script totaly stop
        reaper.SetToggleCommandState(sectionId, cmdId, 0) --set toggle state to Off in action list
        reaper.RefreshToolbar2(sectionId, cmdId)--set toggle State to Off in toolbar
        cleanArrangeView()--clean folder track from every empty items except those with MIDI data
      end)
    end
  end)()
    
--
--[[ CORE ]]--
--
function Main()
  
  nbrOfTrack =  reaper.CountTracks(0)--nbre of track in the project
  
    for i=0, nbrOfTrack-1 do
    -- for each track
    track =  reaper.GetTrack( 0, i ) --we get info from the current track
    trackFolderDepth = reaper.GetMediaTrackInfo_Value( track, "I_FOLDERDEPTH") --we check if it's a folder or not

        if trackFolderDepth > 0.0 then -- if we are on a folder track
      deleteEmptyItemsOnTracks(track)--we clean the tracks from empty items    
            createLogicXItem(track)-- Once track is cleared from empty items but still has items with MIDI data, we create an empty item
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

-- Begining of the undo block. Leave it at the top of your main function.
reaper.Undo_BeginBlock() 

-- execute script core
Main()

-- update arrange view UI
reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
