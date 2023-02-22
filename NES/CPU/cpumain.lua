local opcodeTable = require("NES.CPU.OpCodes.TABLEOFOPCODE")
local cpuMemory   = require("NES.CPU.cpumemory")
local cart        = require("NES.Cartridge.Cartridge")
local ppu         = require("NES.PPU.ppu")
local ppuIO       = require("NES.PPU.ppuIO")
local bus         = require("NES.BUS.bus")
local addressMode = require("NES.CPU.OpCodes.addressmodes")

-- 6502 CPU
local cpu         = {}
local rshift, band, bor = bit.rshift, bit.band, bit.bor

function cpu.Initialize(startPCAt)
    cpuMemory.A              = 0x01
    cpuMemory.X              = 0x02
    cpuMemory.Y              = 0x03
    cpuMemory.stackPointer   = 0xFD
    cpuMemory.statusRegister = 0x24
    cpuMemory.info.cycle     = 7
    cpuMemory.info.execute   = 0
    --memory.Initialize(0x00)
    print(bus.CPURead(0xfffb))
    cpuMemory.NMIInterrupt   = bus.CPURead(0xfffb) * 256 + bus.CPURead(0xfffa)
    -- Change Startup for Debug nesTest
    if startPCAt then
        cpuMemory.programCounter = startPCAt
    else
        cpuMemory.programCounter = bus.CPURead(0xfffd) * 256 + bus.CPURead(0xfffc)
        print("CPU ini ",cpuMemory.programCounter)
    end
    cpuMemory.BRKInterrupt = bus.CPURead(0xffff) * 256 + bus.CPURead(0xfffe)

    cpuMemory.CHRLocation  = cart.header[0x04] * 0x4000 + 0x010 -- offset Header

    print(string.format("NMI:%x, PC:%x, BRK:%x, CHRLocation:%x CartMapper:%x", cpuMemory.NMIInterrupt, cpuMemory.programCounter,
        cpuMemory.BRKInterrupt, cpuMemory.CHRLocation, cart.mapper))
    print("CPU Initialized")
end


function cpu.DoNMI()
    --print("NMI Trigger")    
    cpuMemory.TriggerNMI = false
     -- Store Highbyte current Stack
    addressMode.WriteToStack(rshift(cpuMemory.programCounter, 8))
    -- Store Lowbyte current Stack
    addressMode.WriteToStack(band(cpuMemory.programCounter, 0xFF))
    -- Processor Status To Stack
    addressMode.WriteToStack(bor(cpuMemory.statusRegister, 0x30))
    -- jump to NMI vector
    cpuMemory.programCounter = bus.CPURead(0xFFFB) * 256 + bus.CPURead(0xFFFA)
end

function cpu.StartDrawing()
    -- Start Drawing 
    ppu.scanLines = 0
    ppu.scanLinePixels = 0
    -- reset trigger for NMI
    ppu.NMIArmed  = true
end

-- This needs to be As Fast As Possible .. with just Flags it takes 9000 microSeconds to complete .. You have 16600 micros per frame
-- The PPU should probably be done on a second thread


function cpu.ExecuteCycles(totalCycles)
    local cycleCost, cycleCount, pcStep = 0, 0, 0
    local table = opcodeTable
    local checkppu = ppu.Update
    local bus = bus.CPURead

    while totalCycles > cycleCount do
        -- Reset PPU with CPU
        if ppu.scanLines == -1 then
            cpu.StartDrawing()
        end
        -- Handle NMI
        if cpuMemory.TriggerNMI then
            cpu.DoNMI()
        end
        -- Get current opcode to execute
        opcode = table[bus(cpuMemory.programCounter)]
        if opcode == nil or opcode == 0x00 then
            print("NIL OPCODE or 0x00!!!", opcode)
        end
        -- Execute opcode
        cycleCost, pcStep        = opcode.func()
        cpuMemory.programCounter = band((cpuMemory.programCounter + pcStep), 0xFFFF)

        -- Update cycle count and debug information
        cycleCount               = cycleCount + cycleCost
        cpuMemory.info.execute   = cpuMemory.info.execute + 1
        cpuMemory.info.cycle     = cycleCost + cpuMemory.info.cycle

        -- Update PPU
        checkppu(cycleCost)
        if UseBreakPoint then cycleCount = cpu.BreakPoint(BreakPointValue, totalCycles, cycleCount) end
    end
end

UseBreakPoint = false
BreakPointValue = 0x00
function cpu.BreakPoint(value, totalCycles, cycleCount)
        if cpuMemory.programCounter == value then
            print("Breakpoint Hit "..value)
            step = 0
            return totalCycles
        end
    return cycleCount
end

return cpu
