local cpuMemory = require("NES.CPU.cpumemory")
local addressMode = require("NES.CPU.OpCodes.addressmodes")
local bus = require("NES.BUS.bus")

--[[
RTS - Return from Subroutine
The RTS instruction is used at the end of a subroutine to return to the calling routine. 
It pulls the program counter (minus one) from the stack.
]]--

local opcodes = {
    -- RTS Immediate Mode
    [0x60] = {
        opcode = "RTS",
        pcCounts = 1,
        func = function ()
            local cycleCounts = 6
            local pcCounts = 0
            -- Get Low Byte
            local lowbyte = addressMode.ReadFromStack()
            -- Get High Byte
            local highbyte = addressMode.ReadFromStack() * 256
            -- add 1 to target address
            local targetAddress = highbyte + lowbyte + 1
            -- Jump to Target
            cpuMemory.programCounter = targetAddress
            if addressMode.debug.trace then addressMode.OpcodePrint("RTS","RTS","0x60", lowbyte, highbyte, targetAddress, 0) end
            return cycleCounts, pcCounts
        end
    },
    
}


return opcodes