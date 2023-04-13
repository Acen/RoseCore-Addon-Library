--[[
SideChick
Version: 0.0.1
This is a interoperability addon. See Acen#3040 on Discord for more information.]]
---@class Debug
---@field state boolean
---@field startTimer string
---@field endTimer string
---@field runCount number
---@field maxRunCount number

---@class Interface
---@field font_data_cache table
---@field Font_Data table
---@field options table


---@class SideChick
---@field debug Debug
---@field AcceptedMessageTypes table
---@field ProcessedMessages table
---@field Directories table
---@field state string
---@field lastParsedMessage table
---@field lastProcessedMessage table
---@field messageIndex number
---@field interface Interface
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

SideChick.Directories = {
    luaPath = GetLuaModsPath(),
    addonPath = GetLuaModsPath() .. "/SideChick",
    interfaceSettings = GetLuaModsPath() .. "/SideChick/interface.lua",
    font = GetLuaModsPath() .. "/SideChick/font.png",
    fontData = GetLuaModsPath() .. "/SideChick/font_data.lua",
}

---@type fun(clean: boolean): string
function SideChick.time(clean)
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

---@type fun(message: string): void
local function log(message)
    if (SideChick.debug.state) then
        if(SideChick.interface ~= nil) then
            SideChick.interface.Console.log("   [" .. SideChick.time() .. "] " ..message)
        end
        d("[SideChick:".. SideChick.time() .. "] " .. message)
    else
        d("[SideChick] " .. message)
    end
end

---@type fun(message: string): void
local function info(message)
    if(SideChick.debug.state) then
        if(SideChick.interface ~= nil) then
            SideChick.interface.Console.info("*** [" .. SideChick.time() .. "] " ..message)
        end
        d("[* SideChick:".. SideChick.time() .. "] " .. message)
    else
        d("[* SideChick] " .. message)
    end
end

---@type fun(message: string): void
local function error(message)
    if(SideChick.debug.state) then
        if(SideChick.interface ~= nil) then
            SideChick.interface.Console.error("!!! [" .. SideChick.time() .. "] " ..message)
        end
        d("[!!! SideChick:".. SideChick.time() .. "] " .. message)
    else
        d("[!!! SideChick] " .. message)
    end
end

---@type fun(table: table, key: string): boolean
function SideChick.has(table, key)
    return table[key] ~= nil
end


---@type fun(table: table, value: any): boolean
function SideChick.includes(table, value)
    for _,v in pairs(table) do
        if (v == value) then
            return true
        end
    end
    return false
end


---@type fun(index: number, fresh: boolean): number
function SideChick.getLastMessageKey(index, fresh)
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

---@type fun(count: number): void
function SideChick.getLastMessages(count)
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
        local messageKey = SideChick.getLastMessageKey(i, fresh)
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

        if not (SideChick.has(SideChick.AcceptedMessageTypes, typeIdentifier)) then
            info("Message type not accepted - " .. typeIdentifier)
            break
        end

        local type = SideChick.AcceptedMessageTypes[typeIdentifier]
        if (type == "say") then
            messageName, messageText = SideChick.parseChatMessage(message)
        end
        if(type == "echo") then
            messageName = "System"
            messageText = message.line
        end

        table.insert(messages, {
            ["name"] = messageName,
            ["text"] = messageText,
            ["key"] = messageKey,
            ["type"] = type,
        })
    end

    table.print(messages);

end

---@type fun(message: table): string, string
function SideChick.parseChatMessage(message)
    if not (type(message) == "table") then
        error("Invalid message - not a table")
        return
    end
    local messageName = string.gsub(message.line, "(.*):(%S)(.*)", "%1")
    messageName = string.gsub(messageName, "(.*):(%S)(.*)", "%1")
    local messageText = string.gsub(message.line, "(.*):()", "")

    return messageName, messageText
end

function SideChick.LoadInterface()
    SideChick.state = "loading interface"
    local interface = FileLoad(SideChick.Directories.interfaceSettings)
    SideChick.interface = interface

    SideChick.interface.initialize()
end

---@type fun(): void
function SideChick.startTheParty()
    log("Status: [" .. SideChick.state .. "]")
    -- Load Interface
    SideChick.LoadInterface()
    --log("Status: [" .. SideChick.state .. "]")
    --log("I'm going to run a loop that will get the last message in chat every [Gameloop.Update]. Hold onto your butt.")
    SideChick.state = "running"
end

function SideChick.onDraw()
    if(SideChick.interface ~= nil) then
        SideChick.interface.onDraw()
    end
end

---@type fun(): void
function SideChick.onUpdate()
    if (SideChick.state == "running") then
        if (SideChick.debug.runCount >= SideChick.debug.maxRunCount) then
            log("exit loop")
            SideChick.state = "exited"
            return -- We can kill the onUpdate call because we're over our quota.
        end

        if (SideChick.debug.state) then
            SideChick.debug.startTimer = SideChick.time()
        end
        SideChick.getLastMessages(5)
        if (SideChick.debug.state) then
            SideChick.debug.endTimer = SideChick.time()
        end

        SideChick.debug.runCount = SideChick.debug.runCount + 1


        if (SideChick.debug.state) then
            table.print(SideChick.debug)
            --log("Run Count: " .. SideChick.debug.runCount, SideChick.debug.startTimer, SideChick.debug.endTimer)
        end
    end
end

SideChick.log = log

RegisterEventHandler("Module.Initalize", SideChick.startTheParty, "SideChick.startTheParty")
RegisterEventHandler("Gameloop.Update", SideChick.onUpdate, "SideChick.onUpdate")
RegisterEventHandler("Gameloop.Draw", SideChick.onDraw, "SideChick.onDraw")

