(*
OmniFocus2Reminders - Selection
Created by: Sean Korzdorfer
Created on: 10/23/12 08:53:07
Version 1.0
Version 1.1 - Updated script so it will not clobber existing task notes.
Version: 1.2 - Updated OmniFocus task selection algorithm. Rob Trew's solution improves efficiency and solves full screen troubles.

## Overview

Send selected tasks in OmniFocus to Reminders.app

## Use Case

I like to keep my errand tasks in OmniFocus, but I also want the convenience of shared family shopping lists
via Reminders.

## Notes

You can configure the script to:

- Send OmniFocus tasks to multiple Reminders lists or a single list
- Complete OmniFocus task after sent to the Reminders app. (cleanUp:"complete")
- Keep OmniFocus task active and note it with date/time sent to Reminders (cleanUp:"link")

NB: The default cleanUp is link. Note you can use this script with OF2Reminders-Sync to complete the tasks in 
 OmniFocus once they have been completed in Reminders. 
 
*)(* ################################ CONFIGURATION ################################ *)-- if you want to keep the OmniFocus tasks active, set cleanUp to "link"-- if yoy want to complete the OmniFocus tasks after sending them to Reminders app-- set cleanUp to "complete"property cleanUp : "link"-- If you want to send OmniFocus tasks to multiple Reminders lists, set listMode to "multi"-- If you want to sent OmniFocus tasks to a single lise, set listMode to "single"property listMode : "multi"-- If you have, say multiple shared shopping lists in the Reminders App whose -- name match an OmniFocus context name, add them the the contextList property:property contextList : {"costco", "trader joe's", "petsmart", "target", "price chopper", "cvs", "amazon", "petco"}-- defaultList is the name of the Reminders list you want any task without a context to go.property defaultList : "Reminders"-- Task selection algorithm by Rob Trew (via email) Thanks Rob!on run	tell application id "OFOC"		tell front document window of default document			repeat with oPanel in {content, sidebar}				tell oPanel to set lstSeln to (value of selected trees of oPanel where its class of its value is not item and class of its value is not folder and class of its value is not project)				if lstSeln ≠ {} then exit repeat			end repeat						if lstSeln ≠ {} then				repeat with oTask in lstSeln										try						-- get a list of tasks who are not missing a context, and whose context name can be found in contextList						if listMode is "multi" and context of oTask is not missing value and contextList contains the name of the context of oTask then							set thelist to the name of the context of oTask						else							set thelist to defaultList						end if					on error						display dialog						"There was an error getting the context for the task" & name of oTask					end try					if note of oTask is not "" then						set theNote to "OF2Reminders: " & (current date) & return & return & "Initial Notes For This Task Before Sync:" & return & return & note of oTask						set note of oTask to theNote					else						set theNote to "OF2Reminders: " & (current date) & return						set note of oTask to theNote					end if										-- First Test: Future Start Date found					if start date of oTask is not missing value and start date of oTask is greater than (current date) then						my createReminder(thelist, name of oTask, start date of oTask, ("omnifocus:///task/" & id of oTask as rich text) & return & return & theNote)						-- Second Test: No valid start date, but future due date found					else if due date of oTask is not missing value and the due date of oTask is greater than (current date) then						my createReminder(thelist, name of oTask, due date of oTask, ("omnifocus:///task/" & id of oTask as rich text) & return & return & theNote)						-- No valid start date or due date found. I could test for start date > due date, but that's on the user.					else						my createReminder(thelist, name of oTask, missing value, ("omnifocus:///task/" & id of oTask as rich text) & return & return & theNote)					end if										-- test CleanUp					if cleanUp is "complete" then set completed of oTask to true					-- 				end repeat			end if		end tell	end tellend run(* 
################################ Create Reminder Task ################################ 

Input: 
- The Reminders list to send the task to
- The name of the OmniFocus task
- The date object of the OmniFocus task
- The note of the OmniFocus task
Output: A Reminders Task

Modifies the OmniFocus Task object's note field to 

	OF2Reminder: <date>

*)on createReminder(thelist, theTask, theDate, theNote)	try		-- test cleanUp property		if cleanUp is not "link" then set theNote to ""		if theDate is not missing value then			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:theTask, remind me date:theDate, body:theNote}		else			tell application "Reminders" to tell list thelist of default account to make new reminder with properties {name:theTask, body:theNote}		end if	on error		display dialog		"There was an error creating a reminder for the task" & theTask	end tryend createReminder