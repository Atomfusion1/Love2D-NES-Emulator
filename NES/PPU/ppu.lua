local memory    = require("NES.CPU.cpuram")
local cpuMemory = require("NES.CPU.cpumemory")
local bus       = require("NES.BUS.bus")
local PPUtoLove = require("NES.PPU.PPUtoLove2d")
local nameTable = require("NES.PPU.ppunametable")
local ppuReg    = require("NES.PPU.ppuIO")
local ppuOAM    = require("NES.PPU.ppuOAM")
local loopy     = require("NES.PPU.loopy")

ppu           = {}
ppu.memory    = {}
ppu.Name      = {}
ppu.Palette   = {}
ppu.Pattern   = {}
ppu.scanLinePixels  = 0
ppu.scanLines       = 30
ppu.vBlankEnd       = false


ppu.scroll = {
    fineX   = 0,
    courseX = 0,
    fineY   = 0,
    courseY = 0
}
function ppu.Initialize(value, chrLocation)
    -- Main PPU (addresses $0200-$FFFF)
    for i = 0x0000, 0xFFFF do
        ppu.memory[i] = bit.band(value, 0xFF)
    end
    print("chrlocation:" .. chrLocation)
    --ppu.memory = Rom.ParseCHR(ppu.memory, chrLocation)
end

function ppu.Update(cpuCycles)
    local ppuCycles = cpuCycles * 3
    local Sprite0Scanline = ppuOAM[0]+1
    local STATUS = ppuReg.STATUS
    local CTRL = ppuReg.CTRL
    local scanLines = ppu.scanLines
    local scanLinePixels = ppu.scanLinePixels
    local NMIArmed = ppu.NMIArmed
    local loopy = loopy
    local band, bor = bit.band, bit.bor

    while ppuCycles > 0 and not ppu.vBlankEnd do
        -- Increment scanline pixel count
        scanLinePixels = scanLinePixels + 1

        -- Check if the first sprite of the scanline is visible
        if scanLines == Sprite0Scanline and not (band(STATUS, 0x40) > 0) then
            STATUS = bor(STATUS, 0x40)
            loopy.sprite0Scanline = scanLines
        end

        -- Check if we've reached the end of a scanline
        if scanLinePixels >= 341 then
            scanLinePixels = 0
            scanLines = scanLines + 1
        end

        -- Check if we're in vBlank
        if scanLines >= 241 then
            if not (band(STATUS, 0x80) > 0) then
                -- Set vBlank 
                loopy.sprite0HitOffset = loopy.course_x
                loopy.sprite0Namespace = loopy.nametable_x
                --print("VBlank Start")           
                STATUS = bor(STATUS,0x80)
            end
            
            if NMIArmed and band(CTRL, 0x80) > 0 then
                -- Set CPU NMI
                cpuMemory.TriggerNMI = true
                ppu.NMIArmed = false
            end
            -- Check if vBlank has ended
            if scanLines >= 261 then
                --print("VBlank End")
                scanLines = -1
                STATUS = 0x00
                loopy.startOffset = loopy.course_x
                loopy.startNamespace = loopy.nametable_x
            end
        end
        -- Decrement cycle count
        ppuCycles = ppuCycles - 1
    end

    ppu.scanLines = scanLines
    ppu.scanLinePixels = scanLinePixels
    ppuReg.STATUS = STATUS
end


-- MAIN DRAW
-- DRAW SCREEN
local imageX = 256
local imageY = 224
-- Screen Buffer -- buffer to store the image data This STARTS Alpha 0
ppu.screenBuffer = love.image.newImageData(imageX, imageY, "rgba8")
ppu.screenImage = love.graphics.newImage(ppu.screenBuffer)
-- CHR Buffer 0
ppu.patternbuffer0 = love.image.newImageData(128, 128, "rgba8")
ppu.patternScreen0 = love.graphics.newImage(ppu.patternbuffer0)
-- CHR Buffer 1
ppu.patternbuffer1 = love.image.newImageData(128, 128, "rgba8")
ppu.patternScreen1 = love.graphics.newImage(ppu.patternbuffer1)

-- screen buffer setup
local pixelCount = imageX * imageY
local screenArray = {}

for i = 0, 4 * pixelCount - 1 do
    screenArray[i] = 0
end

function ppu.FFIBuffer(ArrayToRender, screenImage, buffer)
    if collectgarbage("count") > 20000 then collectgarbage() end -- This is BAD I do not want this
    local pointer = require("ffi").cast("uint8_t*", buffer:getFFIPointer())
    pixelCount = (4 * screenImage:getWidth() * screenImage:getHeight()) - 1
    for i = 0, pixelCount, 4 do
        pointer[i] = ArrayToRender[i] or 0
        pointer[i + 1] = ArrayToRender[i + 1] or 0
        pointer[i + 2] = ArrayToRender[i + 2] or 0
        pointer[i + 3] = ArrayToRender[i + 3] or 0
    end
    screenImage:replacePixels(buffer)
end

-- HACK CHECK 
function ppu.ScreenToNumbers()
    local pattern = ppu.patternScreen0
    -- course x y 
    for y=0, 29 do
        for x=0, 31 do
            -- Draw Hex Values of Nametable to screen 
            --if nameTable.tblName[0][1] then love.graphics.print(string.format("%x",nameTable.tblName[0][y*16+x]), x*20+15, y*16+10) end
            -- draw sprites 
            local id = nameTable.tblName[0][y*32+x]
            -- HACK
            if r then 
                pattern = ppu.patternScreen0
            else
                pattern = ppu.patternScreen1
            end
            love.graphics.draw(
                pattern,
                love.graphics.newQuad(bit.lshift(bit.band(id, 0x0F), 3), bit.lshift(bit.band(bit.rshift(id, 4), 0x0F), 3), 9, 9, 128, 128),
                x * 16+15, y * 16+10,nil,2
            )
        end
    end
end

function ppu.StartGameWindow()
    PPUtoLove.DrawBackground(screenArray, r and 1 or 0)
    PPUtoLove.DrawSprites(screenArray,not r and 1 or 0)
    ppu.FFIBuffer(screenArray, ppu.screenImage, ppu.screenBuffer)
end

function ppu.DrawMainScreen()
    PPUtoLove.PPUDrawMainScreen(screenArray)
    ppu.FFIBuffer(screenArray, ppu.screenImage, ppu.screenBuffer)
end

-- char buffer setup
local CHR0 = {}
local CHR1 = {}
function ppu.StartCharacterTiles()
    PPUtoLove.DrawCHR(CHR0, 0)
    ppu.FFIBuffer(CHR0, ppu.patternScreen0, ppu.patternbuffer0)
    PPUtoLove.DrawCHR(CHR1, 1)
    ppu.FFIBuffer(CHR1, ppu.patternScreen1, ppu.patternbuffer1)
end

function ppu.GameWindow()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(ppu.screenImage, 15, 10, 0, 2)
end

function ppu.DrawCharacterTiles()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(ppu.patternScreen0, 10, 500, 0, 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(ppu.patternScreen1, 275, 500, 0, 2)
end


return ppu
