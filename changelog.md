# Change Log #

## Of2Reminders-batch.applescript ##

* Removed references to *default account* when creating Reminder. This caused errors when the default account did not contain the necessary task list.
* Added <code>set theTasks to {}</code> to the end of the **repeat iContext** loop. If, within OmniFocus, Context1 had items and Context2 was empty, the items from Context1 would be placed in List1 as well as List2.
