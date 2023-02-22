local bus = require("NES.PPU.ppuBus")
local colors = require("NES.PPU.VGA_Pallette")
local nameTable = require("NES.PPU.ppunametable")
local OAM = require("NES.PPU.ppuOAM")
local ppuIO = require("NES.PPU.ppuIO")
local loopy = require("NES.PPU.loopy")

local PPUtoLove2d = {}
PPUtoLove2d.PointerArray = {}

local band, lshift, rshift,bor = bit.band,bit.lshift,bit.rshift, bit.bor
local PPURead = bus.PPURead

function PPUtoLove2d.DrawCHR(array, CHRTileSet)
    for nTileY = 0, 15 do
        for nTileX = 0, 15 do
            local nOffset = nTileY * 256 + nTileX * 16
            for littleY = 0, 7 do
                local i = CHRTileSet
                local tile_lsb = PPURead(i * 0x1000 + nOffset + littleY)
                local tile_msb = PPURead(i * 0x1000 + nOffset + littleY + 8)
                local x_offset = nTileX * 8
                local y_offset = nTileY * 8 * 128 + littleY * 128
                for x = 7, 0, -1 do
                    local pixel = bor(band(tile_lsb, 0x01), lshift(band(tile_msb, 0x01), 1))
                    tile_msb = rshift(tile_msb, 1)
                    tile_lsb = rshift(tile_lsb, 1)
                    local pixelIndex = 4 * (x_offset+x + y_offset)
                    Setup1DArray(0x3F00 + y * 4 + pixel, array, pixelIndex)
                end
            end
        end
    end
end

local function SelectAttributeValue(attributeTable, c_X, c_Y)
    local Attr_X = c_X % 4 -- get the last 2 bits of c_X
    local Attr_Y = c_Y % 4 -- get the last 2 bits of c_Y
    local offset = math.floor(Attr_Y / 2) * 4
    local shift = math.floor(Attr_X / 2) * 2
    return band(rshift(attributeTable, offset + shift), 0x03)
end

-- Draw Background 
function PPUtoLove2d.DrawBackground(array, CHRTileSet)
    local i = ppuIO.BackgroundTable
    local tableValue = 0--loopy.startNamespace -- HACK
    local offset = loopy.startOffset
    local Sprite0Offset = loopy.sprite0HitOffset
    local Sprite0ScanLine = loopy.sprite0Scanline
    --print(loopy.fine_x)
    for c_Y = 0, 29 do
        for fine_Y = 0, 7 do
            if (c_Y * 8 + fine_Y-7) == Sprite0ScanLine then
                offset = Sprite0Offset
                tableValue = loopy.sprite0Namespace
            end
            for c_X = 0, 31 do
                local scrollX = c_X + offset
                local id, attributeTable
                if scrollX > 31 then
                    local delta = tableValue == 0 and 1 or -1
                    local attributePointer = (rshift(c_Y, 2)-1) * 8 + rshift(scrollX, 2) + 0x03C0
                    id = nameTable.tblName[tableValue+delta][(c_Y) * 32 + scrollX-32]                    
                    attributeTable = nameTable.tblName[tableValue+delta][attributePointer]
                else
                    local attributePointer = rshift(c_Y, 2) * 8 + rshift(scrollX, 2) + 0x03C0
                    id = nameTable.tblName[tableValue][c_Y * 32 + scrollX]
                    attributeTable = nameTable.tblName[tableValue][attributePointer]
                end
                local nAddress = i * 0x1000 + id * 16 + fine_Y
                local tile_lsb = PPURead(nAddress)
                local tile_msb = PPURead(nAddress + 8)
                local attributeValue = SelectAttributeValue(attributeTable, scrollX, c_Y)
                for fine_X = 7, 0, -1 do
                    local pixel = bor(band(tile_lsb, 0x01), lshift(band(tile_msb, 0x01), 1))
                    tile_msb = rshift(tile_msb, 1)
                    tile_lsb = rshift(tile_lsb, 1)
                    local offset = 4 * (c_X * 8 + fine_X + (c_Y-1) * 2048 + fine_Y * 256)
                    if pixel == 0 then
                        Setup1DArray(0x3F00, array, offset)
                    else
                        Setup1DArray(0x3F00 + attributeValue * 4 + pixel, array, offset)
                    end
                end
            end
        end
    end
end

-- Draw Sprites 
function PPUtoLove2d.DrawSprites(array, CHRTileSet)
    local i = ppuIO.SpriteTable
    local numSprites = 64
    for spriteIndex = 0, numSprites - 1 do
        local littleY = OAM[spriteIndex * 4 + 0]
        --print(spriteIndex, string.format("%x",littleY))
        if littleY <= 1 or littleY > 239 then
            goto continue
        end
        
        local tileIndex = OAM[spriteIndex * 4 + 1]
        local attributes = OAM[spriteIndex * 4 + 2]
        local palette = band(attributes, 0x03)
        local x = OAM[spriteIndex * 4 + 3]
        local flipH = band(attributes, 0x40) > 0
        local flipV = band(attributes, 0x80) > 0
        local spriteHeight = 8
        
        for fineY = 0, spriteHeight - 1 do
            local nAddress = i * 0x1000 + tileIndex * 16 + fineY
            local tile_lsb = PPURead(nAddress)
            local tile_msb = PPURead(nAddress + 8)
            
            for fineX = 7, 0, -1 do
                local pixel = bor(band(tile_lsb, 0x01), lshift(band(tile_msb, 0x01), 1))
                tile_msb = rshift(tile_msb, 1)
                tile_lsb = rshift(tile_lsb, 1)
                local xIndex = x + (flipH and (7 - fineX) or fineX)
                local yIndex = ((littleY-8) * 256) + (flipV and (7 - fineY) or fineY) * 256
                local pixelIndex = 4 * (xIndex + yIndex)
                if pixel ~= 0 then -- If 0 ignore it (transparent)
                    Setup1DArray(0x3F10 + palette * 4 + pixel, array, pixelIndex)
                end
            end
        end
        ::continue::
    end
end

function Setup1DArray(address,PointerArray, location)
    local color = colors[PPURead(address)]
-- BUG HERE  
    if color ~= nil then
    PointerArray[location],
    PointerArray[location + 1],
    PointerArray[location + 2],
    PointerArray[location + 3] = color[1], color[2], color[3], color[4]
    end
end

return PPUtoLove2d
