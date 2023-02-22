local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    LDX - Load X Register
    X,Z,N = M

    Loads a byte of memory into the X register setting the zero and negative flags as appropriate.
]]--

-- Opcode function 
local function OpcodeFunction(value)
    cpuMemory.CheckZeroAndNegativeFlag(value)
    cpuMemory.X = value
end

local opcodes = {
    -- Immediate Mode
    [0xA2] = {
        opcode = "LDX",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 2
            local pcCounts = 2
            local value = addressMode.GetImmediateMode()
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDX","LDX","0xA2", 0, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Mode
    [0xA6] = {
        opcode = "LDX",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 3
            local pcCounts = 2
            local address = addressMode.GetZeroPageAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDX","LDX","0xA6", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Zero Page Y Mode
    [0xB6] = {
        opcode = "LDX",
        pcCounts = 2,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 2
            local address = addressMode.GetZeroPage_YAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDX","LDX","0xB6", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute Mode
    [0xAE] = {
        opcode = "LDX",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsoluteAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDX","LDX","0xAE", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Absolute,Y Mode
    [0xBE] = {
        opcode = "LDX",
        pcCounts = 3,
        func = function ()
            local cycleCounts = 4
            local pcCounts = 3
            local address = addressMode.GetAbsolute_YAddressMode()
            local value = bus.CPURead(address)
            OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("LDX","LDX","0xBE", address, value, 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes