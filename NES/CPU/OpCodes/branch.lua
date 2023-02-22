local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
    BRANCH FUNCTIONS
]]--

local function OpcodeFunction(value)
    local cycleCounts = 2
    local pcCounts = 2
    local new_pc = 0
    local offsetValue = 0
  
    if value then
      cycleCounts = cycleCounts + 1
      offsetValue = addressMode.GetImmediateMode()
  
      if offsetValue >= 0x80 then
        offsetValue = offsetValue - 0x100
      end
  
      new_pc = (cpuMemory.programCounter + 2 + offsetValue)
  
      if (bit.band(cpuMemory.programCounter , 0xff00)) ~= (bit.band(new_pc, 0xff00)) then
        cycleCounts = cycleCounts + 1
      end
  
      pcCounts = 2 + offsetValue
    end
  
    return cycleCounts, pcCounts
  end


local opcodes = {
    -- Branch on Plus
    [0x10] = {
        opcode = "BPL",
        pcCounts = 2,
        func = function ()
            -- true if not negative flag == 0 
            local value = (cpuMemory.ReadFlag("negative") == 0)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BPL","BPL","0x10", 0, cpuMemory.ReadFlag("negative"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Branch on Minus
    [0x30] = {
        opcode = "BMI",
        pcCounts = 2,
        func = function ()
            -- true if negative flags 
            local value = (cpuMemory.ReadFlag("negative") == 1)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BMI","BMI","0x30", 0, cpuMemory.ReadFlag("negative"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },

    -- Branch Carry Clear
    [0x90] = {
        opcode = "BCC",
        pcCounts = 2,
        func = function ()
            -- true if not carry flag == 0 
            local value = (cpuMemory.ReadFlag("carry") == 0)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BCC","BCC","0x90", 0, cpuMemory.ReadFlag("carry"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Branch on Carry Set
    [0xB0] = {
        opcode = "BCS",
        pcCounts = 2,
        func = function ()
            -- true if carry flag
            local value = (cpuMemory.ReadFlag("carry") == 1)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BCS","BCS","0xB0", 0, cpuMemory.ReadFlag("carry"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Branch on Overflow Clear 
    [0x50] = {
        opcode = "BVC",
        pcCounts = 2,
        func = function ()
            -- true if not overflow
            local value = (cpuMemory.ReadFlag("overflow") == 0)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BVC","BVC","0x50", 0, cpuMemory.ReadFlag("overflow"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Branch on Overflow Set
    [0x70] = {
        opcode = "BVS",
        pcCounts = 2,
        func = function ()
            -- true if overflow
            local value = (cpuMemory.ReadFlag("overflow") == 1)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BVS","BVS","0x70", 0, cpuMemory.ReadFlag("overflow"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Branch on Not Equal 
    [0xD0] = {
        opcode = "BNE",
        pcCounts = 2,
        func = function ()
            -- true if Not zero Falg
            local value = (cpuMemory.ReadFlag("zero") == 0)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BNE","BNE","0xD0", 0, cpuMemory.ReadFlag("zero"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
    -- Branch on Equal 
    [0xF0] = {
        opcode = "BEQ",
        pcCounts = 2,
        func = function ()
            -- true if zero Flag
            local value = (cpuMemory.ReadFlag("zero") == 1)
            local cycleCounts, pcCounts = OpcodeFunction(value)
            if addressMode.debug.trace then addressMode.OpcodePrint("BEQ","BEQ","0xF0", 0, cpuMemory.ReadFlag("zero"), 0, 0) end
            return cycleCounts, pcCounts
        end
    },
}


return opcodes