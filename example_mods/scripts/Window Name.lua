local difficulties = {
    "Easy",
    "Normal",
    "Hard",
    "Harder",
    "Ow my hands",
}

local oldTitle = "Friday Night Funkin: Joalor64 Engine Rewritten"

function onCreate()
    oldTitle = (getPropertyFromClass("openfl.Lib", "application.window.title") or "Friday Night Funkin': Joalor64 Engine Rewritten")
    setPropertyFromClass("openfl.Lib", "application.window.title", oldTitle .. " - NOW PLAYING: " .. (songName))
end

function onDestroy()
    setPropertyFromClass("openfl.Lib", "application.window.title", oldTitle)
end

function onCreatePost()
    setPropertyFromClass("openfl.Lib", "application.window.title", oldTitle .. " - NOW PLAYING: " .. (songName) .. " on " .. difficulties[difficulty])
end

-- Credits
-- Original by P00P36#7620
-- Improved by Superpowers04#3887