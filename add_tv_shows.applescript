-- Add the movie at the given path and set its genre
to AddToITunes(theNewPath, theSeriesName, theSeriesNumber, theEpisodeName, theEpisodeNumber)
	tell application "iTunes"
        copy (add theNewPath) to newMovie
--		set newMovie to add (POSIX file theNewPath)

--        set newMovie to add theNewPath		
		set video kind of newMovie to TV show
		set ((season number) of newMovie) to (theSeriesNumber as number)
		set show of newMovie to theSeriesName --& " " & theSeriesNumber
		if (theEpisodeName is not "") then
			set (name of newMovie) to theEpisodeName
		else
			set (name of newMovie) to "Episode " & theEpisodeNumber
		end if
		--set ((episode ID) of (newMovie)) to "S" & theSeriesNumber & "E" & theEpisodeNumber
		set ((episode ID) of (newMovie)) to "S" & theSeriesNumber & "E" & theEpisodeNumber
		set ((episode number) of newMovie) to (theEpisodeNumber as number)
		set ((sort show) of (newMovie)) to theSeriesName & " S" & theSeriesNumber & "E" & theEpisodeNumber
	end tell
end AddToITunes

property kFileList : {}

-- http://stackoverflow.com/questions/2097263/get-full-directory-contents-with-applescript
-- Little tweaks added to return alias list instead of just a filename.
on CreateList(mSource_folder)
    set item_list to ""

    tell application "System Events"
        set item_list to get the name of every disk item of mSource_folder
    end tell

    set item_count to (get count of items in item_list)

    repeat with i from 1 to item_count
        set the_properties to ""

        set the_item to item i of the item_list
        set the_item to ((mSource_folder & the_item) as string) as alias

        tell application "System Events"
            set file_info to get info for the_item
        end tell

        if visible of file_info is true then
            set file_name to displayed name of file_info
--            set end of kFileList to (POSIX path of mSource_folder) & file_name
            set end of kFileList to the_item
            if folder of file_info is true then
                my createList(the_item)
            end if
        end if

    end repeat
end createList

with timeout of 86400 seconds
	mount volume "smb://fileserver.phantomdata.com/Media/"
	
--	set mediaPath to "/Volumes/media/Apple/" as POSIX file as alias
--	error mediaPath
    
    set mediaPath to "Media:TV Shows" as alias
	set mediaPath to "/Users/jordancox/Desktop/" as POSIX file as alias
	
--	tell application "Finder"
--		set l to (files of entire contents of folder (mediaPath as POSIX file) whose name extension is "mp4") as alias list
--	end tell
	my CreateList(mediaPath)
--	repeat with f in kFileList
    repeat with i from 1 to (get count of items in kFileList)
        try
            set f to item i of kFileList
    		set p to (POSIX path of f)
    	    if (".mp4" is in p) then
        		-- Get the metadata
        		find text ".*/(.*?) S([0-9]{2})E([0-9]{2}) (.*?)$" in p using "\\1" with regexp and string result
        		set title to result
        		find text ".*/(.*?) S([0-9]{2})E([0-9]{2}) (.*?)$" in p using "\\2" with regexp and string result
        		set season to result
        		find text ".*/(.*?) S([0-9]{2})E([0-9]{2}) (.*?)$" in p using "\\3" with regexp and string result
        		set episode_number to result
        		find text ".*/(.*?) S([0-9]{2})E([0-9]{2}) (.*?).mp4$" in p using "\\4" with regexp and string result
        		set episode_name to result
		
        		-- See if it already exists
        		tell application "iTunes"
        			set results to (search library playlist "Library" for (title & " " & episode_name))
        		end tell
        		-- If it isn't already in the library, pop it in there.
        		if (results's length is equal to 0) then
    				AddToITunes(f, title, season, episode_name, episode_number)
        		end if
    		end if
    	on error error_string number error_number
    	end try
	end repeat
end timeout