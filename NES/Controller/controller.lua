local controller             = {}

controller.Controller1State  = 0x00
controller.Controller2State  = 0x00
local Controller1FreezeState = 0x00
local Controller2FreezeState = 0x00

function controller.ReadState(addr)
    if addr == 0x4016 then
        local data             = bit.band(Controller1FreezeState, 0x80) > 0 and 1 or 0
        Controller1FreezeState = bit.lshift(Controller1FreezeState, 1)
        --print("Read State of Controller ",string.format("%x",addr), data,Controller1FreezeState)
        return data
    end
    if addr == 0x4017 then
        local data             = bit.band(Controller2FreezeState, 0x80) > 0 and 1 or 0
        Controller2FreezeState = bit.lshift(Controller2FreezeState, 1)
        return data
    end
end

-- Write 4016
function controller.GetState(addr)
    if addr == 0x4016 then Controller1FreezeState = controller.Controller1State end
    if addr == 0x4017 then Controller2FreezeState = controller.Controller2State end
end

return controller
