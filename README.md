# MC Reapack repository

This repository contains some scripts for Cockos Reaper D.A.W.

To use these scripts you can install them by using this URL in Reapack : [https://raw.githubusercontent.com/MathieuCGit/MC_VariousScripts/master/index.xml](https://raw.githubusercontent.com/MathieuCGit/MC_VariousScripts/master/index.xml)

# Table of contents

- [MC Reapack repository](#mc-reapack-repository)
  - [MC_ALaLogic_TCP-folder-separator.lua](#mc_alalogic_tcp-folder-separatorlua)
    - [Draw separator on folder track](#draw-separator-on-folder-track)
    - [Options](#options)


## MC_ALaLogic_TCP-folder-separator.lua

	This script aims to reproduce the folder separation in a way Logic X does it.

	![](../img/logic-screenshot01.png)

   ### Draw separator on folder track

   This script aimes to provide a mechanism similar to the one in LogicProX to separate 
   folders in the Arrange View.

   ---
   ### Options

   Actually you have to customize your preferences directly into the script.


   **``TRACK_HEIGHT``**
    This **MUST** be **AT LEAST** 2 pixels higher than the size defined in Preferences > Apparence > Media > "Hide labels for items when item take lane height is less than". 
    You also have to uncheck "draw labels above items, rather than within items"
    _Default value is **``28``**_ but I got better result with 20pixels.
   - Default 6 and dafault 5 theme TRACK_HEIGHT=25. 
   - 25 Also works with Jane, Funktion.
   - iLogic V2 = 28
   - iLogic V3 = 24
   - Flat Madness and CubeXD= 22

   **``TRACK_COLOR_SINGLE``**
    Do you want all the item folder to get the same color ? Otherwise, default folder track color will be used. _Default is **``0``**_

   **``TRACK_COLOR``**
    Use RGB color code. _Default is **``{111,121,131}``**_

   **``TRACK_COLOR_DARKER_STEP``**
    This is the amount of darkness yo uwant to apply to default track color. 0 means NO darkness. _Default is **``25``**_
  

   ---
