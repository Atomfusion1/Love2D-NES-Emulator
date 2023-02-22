local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    LDY - Load X Register
    X,Z,N = M

    Loads a byte of memory into the X register setting the zero and negative flags as appropriate.
]]--

-- Opcode function 
local function OpcodeFunction(value)
    cpuMemory.CheckZeroAndNegativeFlag(value)
    cpuMemory.Y = value
end

local opcodes = {
    -- Immediate Mode
    [0xA0] = {
        opcode = "LDY",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDY","LDY","0xA0", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0xA4] = {
        opcode = "LDY",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDY","LDY","0xA4", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page X Mode
    [0xB4] = {
        opcode = "LDY",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDY","LDY","0xB4", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xAC] = {
        opcode = "LDY",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDY","LDY","0xAC", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,X Mode
    [0xBC] = {
        opcode = "LDY",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_XAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDY","LDY","0xBC", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes