function PPUtoLove2d.DrawBackgroundWithSprites(array, CHRTileSet, OAMData)
    local i = CHRTileSet
    local tableValue = 0
    local maxValue = 0
    local spriteCache = {}
    local numSpritesOnScanline = 0
    for c_Y = 0, 29 do
        for fine_Y = 0, 7 do
            for c_X=0, 31 do
                -- Draw the background
                local id = nameTable.tblName[tableValue][c_Y * 32 + c_X]
                local nAddress = i * 0x1000 + (id) * 16 + (fine_Y)
                local tile_lsb = bus.PPURead(nAddress)
                local tile_msb = bus.PPURead(nAddress+8)
                for fine_X = 7, 0,-1 do
                    local pixel = bit.bor(bit.band(tile_lsb, 0x01), bit.lshift(bit.band(tile_msb, 0x01), 1))
                    tile_msb = bit.rshift(tile_msb, 1)
                    tile_lsb = bit.rshift(tile_lsb, 1)
                    maxValue = 4 * ((c_X*8 + fine_X) + (c_Y*2048 + fine_Y*256) )
                    Setup1DArray(array, maxValue, pixel)
                end

                -- Draw sprites on top of the background
                numSpritesOnScanline = 0
                for spriteIndex = 0, 63 do
                    local spriteY = OAMData[spriteIndex*4] + 1
                    if spriteY <= c_Y*8 + fine_Y and spriteY + 7 >= c_Y*8 + fine_Y then
                        numSpritesOnScanline = numSpritesOnScanline + 1
                        if numSpritesOnScanline > 8 then
                            -- More than 8 sprites on a scanline, trigger overflow flag
                            bus:Write(0x2002, bit.bor(bus:Read(0x2002), 0x20))
                            break
                        end

                        -- Cache the sprite tile data for this sprite
                        local spriteX = OAMData[spriteIndex*4+3]
                        local spriteAttr = OAMData[spriteIndex*4+2]
                        local spritePatternTableAddr = bit.band(spriteAttr, 0x08) * 0x1000
                        local spritePatternTableIndex = bit.band(spriteAttr, 0x01)
                        local spriteTileIndex = OAMData[spriteIndex*4+1]
                        if not spriteCache[spriteIndex] then
                            spriteCache[spriteIndex] = {}
                        end
                        if not spriteCache[spriteIndex][c_X] then
                            local spriteTileAddr = spritePatternTableAddr + spriteTileIndex * 16
                            local spriteTileLsb = bus:PPURead(spriteTileAddr + fine_Y)
                            local spriteTileMsb = bus:PPURead(spriteTileAddr + fine_Y + 8)
                            spriteCache[spriteIndex][c_X] = {
                                pixelData = {},
                                x = spriteX,
                                attr = spriteAttr,
                            }
                            for spriteFineX = 0, 7 do
                                local spritePixel = bit.bor(
                                    bit.band(spriteTileLsb, 0x01),
                                    bit.lshift(bit.band(spriteTileMsb,0x01), 1))
                                    spriteTileLsb = bit.rshift(spriteTileLsb, 1)
                                    spriteTileMsb = bit.rshift(spriteTileMsb, 1)
                                    spriteCache[spriteIndex][c_X].pixelData[spriteFineX] = spritePixel
                            end
                        end
                        -- Draw the sprite pixel
                        local spriteFineX = (c_X*8 + fine_X) - spriteX
                        local spritePixel = spriteCache[spriteIndex][c_X].pixelData[spriteFineX]
                        if spritePixel ~= 0 then
                            local spriteAttr = spriteCache[spriteIndex][c_X].attr
                            local spritePaletteIndex = bit.band(spriteAttr, 0x03) + 4
                            local paletteRamAddr = 0x3F10 + spritePaletteIndex * 4 + spritePixel
                            local paletteRamValue = bus:Read(paletteRamAddr)
                            local colorIndex = PPUtoLove2d.GetColorIndexFromPaletteRam(paletteRamValue)
                            local arrayIndex = maxValue + 4 * (2048 + spriteIndex * 256 + spriteFineX + (c_Y * 8 + fine_Y - spriteY) * 32 * 8)
                            Setup1DArray(array, arrayIndex, colorIndex)
                        end
                    end
                end
            end
        end
    end
end
