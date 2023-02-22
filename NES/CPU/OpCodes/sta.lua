local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
STA - Store Accumulator
M = A

Stores the contents of the accumulator into memory.
]]


local opcodes = {
    -- ZeroPage
    [0x85] = {
        opcode = "STA",
        pcCounts = 2,
        func = function ()
            local cycles = 3
            local PCCounter = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x85", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- ZeroPage_X
    [0x95] = {
        opcode = "STA",
        pcCounts = 2,
        func = function ()
            local cycles = 4
            local PCCounter = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x95", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute
    [0x8D] = {
        opcode = "STA",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x8D", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute_X
    [0x9D] = {
        opcode = "STA",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x9D", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Absolute_Y
    [0x99] = {
        opcode = "STA",
        pcCounts = 3,
        func = function ()
            local cycles = 4
            local PCCounter = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x99", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Indexed Indirect X
    [0x81] = {
        opcode = "STA",
        pcCounts = 2,
        func = function ()
            local cycles = 6
            local PCCounter = 2
            local address = addressMode.GetIndexed_Indirect_XMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x81", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
    -- Indirect Indexed Y
    [0x91] = {
        opcode = "STA",
        pcCounts = 2,
        func = function ()
            local cycles = 5
            local PCCounter = 2
            local address = addressMode.GetIndirect_Indexed_YMode()
            local value = cpuMemory.A
            bus.CPUWrite(address, value)
            if addressMode.debug.trace then addressMode.OpcodePrint("STA","STA","0x91", address, value, 0, 0) end
            return cycles, PCCounter
        end
    },
}

return opcodes