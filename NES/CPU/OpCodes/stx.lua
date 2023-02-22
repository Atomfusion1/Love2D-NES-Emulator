local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
STX - Store X Register
M = X

Stores the contents of the X register into memory.
]]


local opcodes = {
    -- ZeroPage
    [0x86] = {
        opcode = "STX",
        pcCounts = 2,
        func = function ()
            local cycles = 3
            local PCCounter = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = cpuMemory.X
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STX","STX","0x85", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- ZeroPage_Y
    [0x96] = {
        opcode = "STX",
        pcCounts = 2,
        func = function ()
            local cycles = 4
            local PCCounter = 2
            local address = addressMode.GetZeroPage_YAddressMode()
            local value = cpuMemory.X
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STX","STX","0x95", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute
    [0x8E] = {
        opcode = "STX",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = cpuMemory.X
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STX","STX","0x8D", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
}

return opcodes