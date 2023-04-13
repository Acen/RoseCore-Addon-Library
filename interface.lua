local interface = {}

interface.options = {
    open = false,
    visible = true,
}

local Console = {
    history = {
        {message = "Log -- 0", type = 0},
        {message = "Notice -- 1", type = 1},
        {message = "Error -- 2", type = 2},
        {message = "Info -- 3", type = 3},
    },
}
function Console.clear()
    Console.history = {}
end

function Console.Elements()
    GUI:BeginChild("##SideChick_Console", 0, 0, true)
        if(GUI:SmallButton("Clear")) then
            Console.clear()
        end
        GUI:BeginChild("##SideChick_Console_History", 0, 0, true)
        for _, v in pairs(Console.history) do
            if(v.type == 0) then
                -- Log
                -- White
                GUI:TextColored(1,1,1,1,v.message)
            elseif(v.type == 1) then
                -- Notice
                -- Yellow
                GUI:TextColored(1,1,0,1,v.message)
            elseif(v.type == 2) then
                -- Error
                -- Red
                GUI:TextColored(1,0,0,1,v.message)
            elseif(v.type == 3) then
                -- Info
                -- Blue
                GUI:TextColored(0,0,1,1,v.message)
            end
        end
        GUI:EndChild()
    GUI:EndChild()
end

function Console.log(message)
    table.insert(Console.history, {message = message, type = 0})
end

function Console.notice(message)
    table.insert(Console.history,{mesage = message, type = 1})
end

function Console.error(message)
    table.insert(Console.history,{mesage = message, type = 2})
end

function Console.info(message)
    table.insert(Console.history,{mesage = message, type = 3})
end

local function initialize()
    ml_gui.ui_mgr:AddMember({ id = "FFXIVMINION##MENU_SideChick", name = "SideChick", onClick = function() interface.options.open = not interface.options.open end, tooltip = "Talk to your SideChick"},"FFXIVMINION##MENU_HEADER")

    Console.log("Log Test.")
end

local function onDraw()
    local gamestate = GetGameState()
    if ( gamestate == FFXIV.GAMESTATE.INGAME ) then
        if ( interface.options.open ) then
            GUI:SetNextWindowSize(580,300,GUI.SetCond_FirstUseEver)
            interface.options.visible, interface.options.open = GUI:Begin("SideChick", interface.options.open, GUI.WindowFlags_NoCollapse)
            GUI:BeginChild("##SideChick", 0, 0, true)
                GUI:Text("Status - " .. SideChick.state)
                Console.Elements()
            GUI:EndChild()
            GUI:End()
        end
    end
end

interface.onDraw = onDraw
interface.initialize = initialize

interface.Console = Console

return interface