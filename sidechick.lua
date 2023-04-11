SideChick = {
    state = "running"
}
SideChick.debug = {
}

function SideChick.Timer()
end


function SideChick.GetLastMessage(runTimer)
    if (SideChick.debug.runCount > SideChick.debug.maxRunCount) then
        d("exit loop")
        SideChick.state = "exited"
        return
    end
    if not (type(runTimer) == "boolean") then
        --d("runTimer not boolean: " .. type(runTimer))
        runTimer = false
    --else
    --    d("runtimer is boolean")
    end

    -- Run timer for speeeeeed test
    if (runTimer) then
        local ioHandle = io.popen("echo %time%")
        SideChick.debug.startTimer = ioHandle:read("*a")
        ioHandle:close()
    end

    local mostRecentMessageKey = 0
    for k in pairs(GetChatLines()) do
        mostRecentMessageKey = math.max(k, mostRecentMessageKey)
    end

    d(GetChatLines()[mostRecentMessageKey].line)

    if (runTimer) then
        local ioHandle = io.popen("echo %time%")
        SideChick.debug.endTimer = ioHandle:read("*a")
        ioHandle:close()
    end

end


function SideChick.StartTheParty()
    SideChick.debug = {
        state = false,
        startTimer = "",
        endTimer = "",
        runCount = 0,
        maxRunCount = 5,
    }
end

function SideChick.OnUpdate()
    if (SideChick.state == "running") then
        SideChick.GetLastMessage(SideChick.debug.state)

        if (SideChick.debug.state) then
            d("Run Count: " .. SideChick.debug.runCount, SideChick.debug.startTimer, SideChick.debug.endTimer)
        end
        SideChick.debug.runCount = SideChick.debug.runCount + 1
    end
end

RegisterEventHandler("Module.Initalize", SideChick.StartTheParty, "SideChick.Init")
RegisterEventHandler("Gameloop.Update", SideChick.OnUpdate, "SideChick.OnUpdate")