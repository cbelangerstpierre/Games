Game3 = {}

function Game3:load()
    require("Defender.Heart")
    require("Defender.Fireball")
    require("Defender.Shield")
    
    WINDOW_WIDTH = 720
    WINDOW_HEIGHT = 720
    HEARTH_WIDTH = 30
    HEARTH_HEIGHT = 30
    FIREBALL_WIDTH = 41
    FIREBALL_HEIGHT = 21
    SHIELD_WIDTH = 19
    SHIELD_HEIGHT = 75
    
    level = 1
    numberOfHearts = 3
    currentFireballDistance = 400
    fireballSpeed = 200
    message = "'Enter' to start"

    file = io.open("Defender/highscore.txt", "r")
    highscore = file:read("*a")
    file:close()

---@diagnostic disable-next-line: discard-returns
    math.randomseed(os.time())

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        resizable = false,
        fullscreen = false
    })

    love.window.setTitle("Defender")

    bigFont = love.graphics.newFont("Defender/fonts/ChrustyRock-ORLA.ttf", 60)
    smallFont = love.graphics.newFont("Defender/fonts/CabalBold-78yP.ttf", 20)

    sounds = {
        ['music'] = love.audio.newSource("Defender/sounds/music.mp3", "static"),
        ['lose'] = love.audio.newSource("Defender/sounds/lose.wav", "static"),
        ['hit'] = love.audio.newSource("Defender/sounds/hit.wav", "static")
    }

    sounds['music']:setVolume(0.8)

    shieldInitialOrientation = 0
    shield = Shield(
        "Defender/imgs/shield2.png",
        WINDOW_WIDTH/2 + SHIELD_HEIGHT/2 * math.sin(math.rad(shieldInitialOrientation)) + 30 * math.cos(math.rad(shieldInitialOrientation)),
        WINDOW_HEIGHT/2 -SHIELD_HEIGHT/2 * math.cos(math.rad(shieldInitialOrientation)) + 30 * math.sin(math.rad(shieldInitialOrientation)),
        SHIELD_WIDTH,
        SHIELD_HEIGHT,
        shieldInitialOrientation)

    hearts = {}
    fireballs = {}

    fireballs[1] = createFireball()
    heartPosUpdate()

    gameState = "start"
    if musicOn and soundsOn then
        mMessage = "'M' to mute music"
    elseif soundsOn then
        mMessage = "'M' to mute sounds"
    else
        mMessage = "'M' to unmute"
    end
end

function heartPosUpdate()
    if numberOfHearts == 3 then
        hearts[1] = createHeart(
        (WINDOW_WIDTH-HEARTH_WIDTH)/2,
        WINDOW_HEIGHT/2 - HEARTH_HEIGHT)
        hearts[2] = createHeart(
        WINDOW_WIDTH/2 - HEARTH_WIDTH,
        (WINDOW_HEIGHT-HEARTH_HEIGHT)/2 + 10)
        hearts[3] = createHeart(
        WINDOW_WIDTH/2,
        (WINDOW_HEIGHT-HEARTH_HEIGHT)/2 + 10)
    elseif numberOfHearts == 2 then
        hearts[1] = createHeart(WINDOW_WIDTH/2 - HEARTH_WIDTH, 
        (WINDOW_HEIGHT-HEARTH_HEIGHT)/2)
        hearts[2] = createHeart(WINDOW_WIDTH/2,
        (WINDOW_HEIGHT-HEARTH_HEIGHT)/2)
        table.remove(hearts, 3)
    elseif numberOfHearts == 1 then
        hearts[1] = createHeart((WINDOW_WIDTH - HEARTH_WIDTH)/2,
        (WINDOW_HEIGHT - HEARTH_HEIGHT)/2)
        table.remove(hearts, 2)
    elseif numberOfHearts == 0 then
        table.remove(hearts, 1)
    end
end

function createHeart(x,y)
    return Heart(
    "Defender/imgs/heart.png",
    x,
    y,
    HEARTH_WIDTH,
    HEARTH_HEIGHT)
end

function createFireball()
    orientation = 0
    randomNum = math.random(4)
    if randomNum == 1 then
        orientation = 90
    elseif randomNum == 2 then
        orientation = 180
    elseif randomNum == 3 then
        orientation = 270
    end
    x = WINDOW_WIDTH/2 + (400 + currentFireballDistance) * -math.cos(math.rad(orientation)) + FIREBALL_HEIGHT/2 * math.sin(math.rad(orientation))
    y = WINDOW_HEIGHT/2 + (400 + currentFireballDistance) * -math.sin(math.rad(orientation)) - FIREBALL_HEIGHT/2 * math.cos(math.rad(orientation))

    currentFireballDistance = currentFireballDistance + math.random(150, 400)

    return Fireball(
    "Defender/imgs/fireball2.png",
    x,
    y,
    FIREBALL_WIDTH,
    FIREBALL_HEIGHT,
    orientation,
    fireballSpeed
    )
end

function Game3:keypressed(key)
    if key == "escape" then
        startTime = os.time()
        love.audio.stop()
        currentGame = "none"
        loadMenu()
    elseif key == "enter" or key == "return" then
        if gameState == "start" then
            if musicOn then
                sounds['music']:play()
                sounds['music']:setLooping(true)
            end
            gameState = "play"
            message = "'Enter' to pause"
        elseif gameState == "play" then
            sounds["music"]:pause()
            gameState = "paused"
            message = "'Enter' to unpause"
        elseif gameState == "paused" then
            sounds["music"]:play()
            gameState = "play"
            message = "'Enter' to pause"
        elseif gameState == "lost" then
            Game3:restart()
        end
    elseif key == "m" then
        if not soundsOn then
            sounds['music']:play()
            sounds['music']:setLooping(true)
            musicOn = true
            soundsOn = true
            mMessage = "'M' to mute music"
        elseif not musicOn then
            soundsOn = false
            mMessage = "'M' to unmute"
        else
            love.audio.stop(sounds['music'])
            musicOn = false
            mMessage = "'M' to mute sounds"
        end
    end
    if gameState == "play" then
        if key == "left" or key == "a" then
            shield.orientation = 180
            shield:update()
        elseif key == "right" or key == "d" then
            shield.orientation = 0
            shield:update()
        elseif key == "up" or key == "w" then
            shield.orientation = 270
            shield:update()
        elseif key == "down" or key == "s" then
            shield.orientation = 90
            shield:update()
        end
    end
end

function Game3:update(dt)
    if level > tonumber(highscore) then
        highscore = level
    end
    if numberOfHearts == 0 then
        sounds["music"]:stop()
        if level == tonumber(highscore) then
            file = io.open("Defender/highscore.txt", "w")
            file:write(level)
            file:close()
        end
        message = "'Enter' to restart"
        gameState = "lost"
    elseif gameState == "play" then
        if tablelength(fireballs) == 0 then
            if level >= 7 then
                fireballSpeed = fireballSpeed + 25
            else
                fireballSpeed = fireballSpeed + 50
            end
            level = level + 1
            currentFireballDistance = 200
            for i = 1,level*2+5, 1 do
                fireballs[i] = createFireball()
            end
        end
        for i = 1, tablelength(fireballs), 1 do
            fireballs[i]:update(dt)
        end
        shield:touchFireball(fireballs)
        Heart:touchFireball(fireballs)
    end
end

function Game3:draw()
    love.graphics.setColor({1, 0, 0})
    love.graphics.setFont(bigFont)
    love.graphics.printf("Defender", 20, 10, WINDOW_WIDTH, "left")
    Game3:displayFPS()
    love.graphics.printf("Highest level: " .. highscore, 30, bigFont.getHeight(bigFont) + 40, WINDOW_WIDTH, "left")
    love.graphics.printf("Level: " .. level, 30, bigFont.getHeight(bigFont) + 60, WINDOW_WIDTH, "left")
    love.graphics.printf("State: " .. gameState, 30, bigFont.getHeight(bigFont) + 80, WINDOW_WIDTH, "left")
    love.graphics.printf(message, WINDOW_WIDTH*2/3, WINDOW_HEIGHT*5/6, WINDOW_WIDTH, "left")
    love.graphics.printf(mMessage, WINDOW_WIDTH*2/3, WINDOW_HEIGHT*5/6 + 20, WINDOW_WIDTH, "left")


    for i = 1,numberOfHearts,1
    do
        hearts[i]:render()
    end

    for i = 1,tablelength(fireballs),1
    do
        fireballs[i]:render()
    end
    shield:render()
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function Game3:displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 30, bigFont.getHeight(bigFont) + 20)
end

function Game3:restart()
    level = 1
    numberOfHearts = 3
    currentFireballDistance = 400
    fireballSpeed = 200
    message = "'Enter' to start"

    hearts = {}
    fireballs = {}

    fireballs[1] = createFireball()
    heartPosUpdate()

    gameState = "start"
end

return Game3