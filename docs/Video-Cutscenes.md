To play an `.mp4`/`.webm` video, you'll need a simple `.lua` script (and, of course, your video).

Here is an example script:
```lua
playVideo = true;

function onStartCountdown()
	if isStoryMode and not seenCutscene then
		if playVideo then --Video cutscene plays
			startVideo('your_video_here', 'type'); --Play video file from "videos/" folder, type can be 'mp4' or 'webm'
			playVideo = false;
			return Function_Stop; --Prevents the song from starting naturally
		end
	end
	return Function_Continue; --Played video, now the song can start normally
end
```

Here's an example script for if you want dialogue after:
```lua
playVideo = true;
playDialogue = true;

function onStartCountdown()
	if isStoryMode and not seenCutscene then
		if playVideo then --Video cutscene plays first
			startVideo('your_video_here', 'type'); --Play video file from "videos/" folder
			playVideo = false;
			return Function_Stop; --Prevents the song from starting naturally
		elseif playDialogue then --Once the video ends it calls onStartCountdown again. Play dialogue this time
			startDialogue('dialogue', 'music'); --"music" is the dialogue music file from "music/" folder
			playDialogue = false;
			return Function_Stop; --Prevents the song from starting naturally
		end
	end
	return Function_Continue; --Played video and dialogue, now the song can start normally
end
```

Alternatively, you can use this code to play videos:
```hx
startVideo('video', 'type');
```