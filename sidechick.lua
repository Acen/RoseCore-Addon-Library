
SideChick = {
    state = "booting",
    lastParsedMessage = {},
    lastProcessedMessage = {},
    messageIndex = 0,
}
SideChick.debug = {
    state = true,
    startTimer = "",
    endTimer = "",
    runCount = 0,
    maxRunCount = 1,
}
SideChick.AcceptedMessageTypes = {
    [56] = "echo",
    [10] = "say",
}
SideChick.ProcessedMessages = {}

function SideChick.Time(clean)
    if not (type(clean) == "boolean") then
        clean = true
    end
    local ioHandle = io.popen("echo %time%")
    local time = ioHandle:read("*a")
    ioHandle:close()
    local cleanTable = {
        ["\n"] = "",
        [":"] = "",
        ["."] = "",
        [" "] = "",
    }
    if (clean) then
        time = time.gsub(time, "[%p\n.(%s+)]", cleanTable)
    end
    return time
end

local function log(message)
    if (SideChick.debug.state) then
        d("[SideChick:".. SideChick.Time() .. "] " .. message)
    else
        d("[SideChick] " .. message)
    end
end

local function error(message)
    if(SideChick.debug.state) then
        d("[!!! SideChick:".. SideChick.Time() .. "] " .. message)
    else
        d("[!!! SideChick] " .. message)
    end
end

function SideChick.Has(table, key)
    return table[key] ~= nil
end

function SideChick.includes(table, value)
    for _,v in pairs(table) do
        if (v == value) then
            return true
        end
    end
    return false
end

function SideChick.GetLastMessageKey(index, fresh)
    if not (type(index) == "number") then
        index = 0
    end
    if(not (type(fresh) == "boolean")) then
        fresh = false
    end
    if not fresh then
        return SideChick.messageIndex + index
    end
    local mostRecentMessageKey = 0
    for k in pairs(GetChatLines()) do
        mostRecentMessageKey = math.max(k, mostRecentMessageKey)
    end
    SideChick.messageIndex = mostRecentMessageKey
    return mostRecentMessageKey + index
end

function SideChick.GetLastMessages(count)
    if(not (type(count) == "number")) then
        count = 1
    end
    count = count - 1
    if(count < 0)then
        log("Provide a number larger than 0")
    end
    local messages = {}
    for i=0,-count,-1 do
        local fresh = false
        if(i == 0) then
            fresh = true
        end
        local messageKey = SideChick.GetLastMessageKey(i, fresh)
        local message = GetChatLines()[messageKey]
        if not (type(message) == "table") then
            error("message is not a table")
            break
        end

        local typeIdentifier = message.code
        if not (type(typeIdentifier) == "number") then
            error("typeIdentifier is not a number")
            error("typeIdentifier: " .. typeIdentifier)
            table.print(message)
        end

        if not (SideChick.Has(SideChick.AcceptedMessageTypes, typeIdentifier)) then
            log("Message type not accepted - " .. typeIdentifier)
            break
        end

        local type = SideChick.AcceptedMessageTypes[typeIdentifier]
        if (type == "say") then
            messageName, messageText = SideChick.ParseChatMessage(message)
        end

        table.insert(messages, {
            ["name"] = messageName,
            ["text"] = messageText,
            ["key"] = messageKey,
            ["type"] = typeIdentifier,
        })
    end

    table.print(messages);

end

function SideChick.ParseChatMessage(message)
    if not (type(message) == "table") then
        error("Invalid message - not a table")
        return
    end
    local messageName = string.gsub(message.line, "(.*):(%S)(.*)", "%1")
    messageName = string.gsub(messageName, "(.*):(%S)(.*)", "%1")
    local messageText = string.gsub(message.line, "(.*):()", "")

    return messageName, messageText
end


function SideChick.StartTheParty()
    log("Status: [" .. SideChick.state .. "]")
    --log("I'm going to run a loop that will get the last message in chat every [Gameloop.Update]. Hold onto your butt.")
    SideChick.state = "running"
end

function SideChick.OnUpdate()
    if (SideChick.state == "running") then
        if (SideChick.debug.runCount >= SideChick.debug.maxRunCount) then
            log("exit loop")
            SideChick.state = "exited"
            return -- We can kill the onUpdate call because we're over our quota.
        end

        if (SideChick.debug.state) then
            SideChick.debug.startTimer = SideChick.Time()
        end
        SideChick.GetLastMessages(5)
        if (SideChick.debug.state) then
            SideChick.debug.endTimer = SideChick.Time()
        end

        SideChick.debug.runCount = SideChick.debug.runCount + 1


        if (SideChick.debug.state) then
            table.print(SideChick.debug)
            --log("Run Count: " .. SideChick.debug.runCount, SideChick.debug.startTimer, SideChick.debug.endTimer)
        end
    end
end

RegisterEventHandler("Module.Initalize", SideChick.StartTheParty, "SideChick.StartTheParty")
RegisterEventHandler("Gameloop.Update", SideChick.OnUpdate, "SideChick.OnUpdate")