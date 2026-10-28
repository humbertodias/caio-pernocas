local kFadeSeconds = 0.6
local kTracks = {
    overworld = "music/menu",
    w1 = "music/w1",
    w2 = "music/w2",
}

local function track_for(scene)
    if scene.name() == "overworld" then return kTracks.overworld end
    local world = CurrentStage and CurrentStage.map_name:match("(w%d)s%d+$")
    return kTracks[world]
end

function play_soundtrack(scene)
    if not music then return end
    local track = track_for(scene)
    if track then
        music.loop(track, kFadeSeconds)
    else
        music.stop(kFadeSeconds)
    end
end
