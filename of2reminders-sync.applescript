(*
OmniFocus2Reminders - Sync
Created by: Sean Korzdorfer
Created on: 10/23/12 08:53:07
Version: 1.0
Version: 1.0.1 2013-02-01 - script no longer clobbers notes.

## Overview

Send all tasks found for the contexts listed in the property contextList to Reminders.app. 
To be used by OF2Reminders or OF2Reminders-batch

## Use Case

I like to keep my errand tasks in OmniFocus, but I also want the convenience of shared family shopping lists
via Reminders.

## Notes

You can use this script with OF2Reminders and OF2Reminders-batch to complete the tasks in 
 OmniFocus once they have been completed in Reminders. 
 
 You can run the script in the background by either creating a launchd item or by using Keyboard Maestro

Requirements:

- In order to send tasks to multiple Reminders lists, the Reminders app list name MUST MATCH the OmniFocus context name.
- To use OF2Reminders-sync script, the notes added to both the OmniFocus and Reminders tasks MUST exist.

*)(* ################################ Script ################################ *)property contextList : {"costco", "trader joe's", "petsmart", "target", "price chopper", "cvs", "Petco"}tell application "Reminders"		if (count of (reminders whose completed is true and body contains "omnifocus:///")) > 0 then		set completedList to reminders whose completed is true and body contains "omnifocus:///"		repeat with theTask in completedList			set ofID to my getID(body of theTask, "omnifocus://")			if my completeOFTask(ofID, body of theTask) is true then				set body of theTask to my deleteLine(body of theTask, "omnifocus://")			end if		end repeat	end ifend tell(* 
################################ Delete the OmniFocus URI from Reminders Task ################################ 

Input: The note text of the Reminders script

Output: The Note text minus the OmniFocus URI

*)on deleteLine(theTxt, deletePhrase)	set txtList to paragraphs of theTxt	repeat with i from 1 to (count txtList)		if (item i of txtList contains deletePhrase) then set item i of txtList to missing value	end repeat	set AppleScript's text item delimiters to return	return txtList's text as textend deleteLine(* 
################################ Delete the OmniFocus URI from Reminders Task ################################ 

Input: The OmniFocus URI

Output: The OmniFocus task ID

*)on getID(theTxt, theURI)	set txtList to paragraphs of theTxt	repeat with i from 1 to (count txtList)		if (item i of txtList contains theURI) then set theID to item i of txtList as text	end repeat	set AppleScript's text item delimiters to "/task/"	return text item 2 of theID as textend getID(* 
################################ Delete the OmniFocus URI from Reminders Task ################################ 

Input: The OmniFocus task id, the Note of the Reminder

Output: nothing

*)on completeOFTask(theID, theNote)	tell application "OmniFocus"		tell default document			--	set lstTasks to flattened tasks where (note contains "of2reminder")			set lstTasks to flattened tasks where (id is theID)			set theSelection to the first item of lstTasks			-- edit here 2013-02-01			set remNote to my deleteLine(theNote, "omnifocus://")			set ofNote to note of theSelection as string			-- Compare the OmniFocus note with the Reminders note - ignoring white space			ignoring white space				if ofNote is not equal to remNote then					set the note of theSelection to the note of theSelection & return & return & "----" & return & return & "Notes synced from Reminders on" & (current date) & ":" & return & remNote				end if			end ignoring			-- edit stop here 2013-02-01			set completed of theSelection to true			return true		end tell	end tellend completeOFTask