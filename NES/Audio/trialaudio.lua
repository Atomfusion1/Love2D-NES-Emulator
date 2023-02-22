function love.load1()
    local sampleRate = 44100
    local frequency = 100
    local duration = 1
    local amplitude = 0.5

    local samplePoints = sampleRate * duration
    local soundData = love.sound.newSoundData(samplePoints, sampleRate, 16, 1)
    local sin = math.sin
    local floor = math.floor
-- Sin Wave
    for i = 0, samplePoints - 1 do
        local time = i / sampleRate
        local value = amplitude * sin(2 * math.pi * frequency * time)
        soundData:setSample(i, value)
    end
-- Pulse Wave  
    for i = 0, samplePoints - 1 do
        local time = i / sampleRate
        local value = (floor(time * frequency * 2) % 2 == 0) and amplitude or -amplitude
        soundData:setSample(i, value*.1)
    end
    local source2 = love.audio.newSource(soundData)
-- Triangle Wave
    for i = 0, samplePoints - 1 do
        local time = i / sampleRate
        local value = ((time * frequency) % 1) * 4 - 2
        if value > 1 then
            value = 2 - value
        elseif value < -1 then
            value = -2 - value
        end
        value = value * amplitude
        soundData:setSample(i, value)
    end


    local source = love.audio.newSource(soundData)
    source2:setLooping(true)
    source:setLooping(true)
    source2:play()
    source:play()
end