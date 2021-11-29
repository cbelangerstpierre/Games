Game1 = {}

function Game1:load()
    WINDOW_WIDTH = 1280
    WINDOW_HEIGHT = 720
    VIRTUAL_WIDTH = 432
    VIRTUAL_HEIGHT = 243
    PLATFORM_WIDTH = 30
    PLATFORM_HEIGHT = 5
    BRICK_WIDTH = 27
    BRICK_HEIGHT = 5
    BALL_RADIUS = 3
    PLATFORM_SPEED = 200
    BALL_SPEED = 100
    NUMBER_OF_BRICKS_WIDTH = VIRTUAL_WIDTH / BRICK_WIDTH
    IMAGE_WIDTH = 512
    IMAGE_HEIGHT = 272
    
    
    push = require "Atari-Breakout.push"
    require "Atari-Breakout.Platform"
    Ball = require "Atari-Breakout.Ball"
    require "Atari-Breakout.Brick"
---@diagnostic disable-next-line: discard-returns
    math.randomseed(os.time())

    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setTitle("Atari Breakout")
    
    smallFont = love.graphics.newFont("Atari-Breakout/font.ttf", 8)
    bigFont = love.graphics.newFont("Atari-Breakout/font.ttf", 16)
    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    sounds = {
        ['platform_hit'] = love.audio.newSource('Atari-Breakout/sounds/platform_hit.wav', 'static'),
        ['lose'] = love.audio.newSource('Atari-Breakout/sounds/lose.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('Atari-Breakout/sounds/wall_hit.wav', 'static'),
        ['score'] = love.audio.newSource('Atari-Breakout/sounds/score.mp3', 'static'),
        ['music'] = love.audio.newSource('Atari-Breakout/sounds/music.mp3', 'static')
    }

    sounds['music']:setVolume(0.2)

    platform = Platform(
    (VIRTUAL_WIDTH - PLATFORM_WIDTH) / 2,
    VIRTUAL_HEIGHT - PLATFORM_HEIGHT - 20,
    PLATFORM_WIDTH,
    PLATFORM_HEIGHT
    )
    
    colors = {{255, 0, 0}, {255, 255, 0}, {0, 255, 0}, {255, 0, 255}, {0, 0, 255}, {0, 255, 255}}
    bricks = {}

    createChooseBalls()
    
    gameState = "choose"
    score = 0
    newBall = 3
    coeffecient = 1
    message = ""
    addedNewBallsPoints = false
    currentLevel = 1
    addedAccelerator = false
    
    highscores = {}
    initialHighscores = {}
    file = io.open("Atari-Breakout/highscore3.txt", "r")
    highscores[1] = file:read("*all")
    initialHighscores[1] = highscores[1]
    file:close()
    
    file = io.open("Atari-Breakout/highscore4.txt", "r")
    highscores[2] = file:read("*all")
    initialHighscores[2] = highscores[2]
    file:close()
    
    file = io.open("Atari-Breakout/highscore5.txt", "r")
    highscores[3] = file:read("*all")
    initialHighscores[3] = highscores[3]
    file:close()
    
    file = io.open("Atari-Breakout/highscore6.txt", "r")
    highscores[4] = file:read("*all")
    initialHighscores[4] = highscores[4]
    file:close()

    if musicOn then
        sounds['music']:play()
        sounds['music']:setLooping(musicOn)
    end

    if musicOn and soundsOn then
        mMessage = "'M' to mute music"
    elseif soundsOn then
        mMessage = "'M' to mute sounds"
    else
        mMessage = "'M' to unmute"
    end

    EnterMessage = ""
end



function lineBrick(NUMBER_OF_BRICKS_HEIGHT)
    NUMBER_OF_BRICKS = NUMBER_OF_BRICKS_HEIGHT * NUMBER_OF_BRICKS_WIDTH
    for i = 1,NUMBER_OF_BRICKS_HEIGHT,1
    do
        for j = 1,NUMBER_OF_BRICKS_WIDTH,1
        do
            bricks[(i - 1) * (NUMBER_OF_BRICKS_WIDTH) + j] = 
            Brick(
            (j - 1) * BRICK_WIDTH,
            (i - 1) * BRICK_HEIGHT + VIRTUAL_HEIGHT/5,
            BRICK_WIDTH,
            BRICK_HEIGHT,
            colors[i]
            )
        end
    end
    gameState = "start"
    createBall()
end

function createBall()
    ball = Ball(
    VIRTUAL_WIDTH / 2,
    VIRTUAL_HEIGHT / 2,
    BALL_RADIUS
    )
end

function Game1:keypressed(key)
    if key == "escape" then
        if gameState == "choose" then
            startTime = os.time()
            love.audio.stop()
            currentGame = "none"
            loadMenu()
        else
            Game1:restart()
        end
    elseif key == "enter" or key == "return" or key == "space" then
        if gameState == "start" and newBall > 0 then
            newBall = newBall - 1
            gameState = "play"
            EnterMessage = "'Enter' to pause"
        elseif gameState == "done" then
            Game1:restart()
        elseif gameState == "play" then
            gameState = "paused"
            EnterMessage = "'Enter' to unpause"
        elseif gameState == "paused" then
            gameState = "play"
            EnterMessage = "'Enter' to pause"
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
    if key == "s" or key == "down" then
        if not addedAccelerator then
            for i = 1,4,1
            do
                chooseBalls[i].dy = chooseBalls[i].dy * 8
            end
            addedAccelerator = true
        end
    end
end

function Game1:update(dt)
    if gameState == "play" or gameState == "choose" then
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            platform.dx = -PLATFORM_SPEED
        elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            platform.dx = PLATFORM_SPEED
        else
            platform.dx = 0
        end
        if gameState == "choose" then
            for i = 1,4,1
            do
                chooseBalls[i]:update(dt)
                if chooseBalls[i]:collidesPlatform(platform) then
                    lineBrick(i+2)
                    currentLevel = i
                    semiReset()
                end
                if chooseBalls[i].y >= VIRTUAL_HEIGHT then
                    addedAccelerator = false
                    createChooseBalls()
                end
            end
        end
        platform:update(dt)
        if gameState == "play" then
            -- platform.x = ball.x-PLATFORM_WIDTH/2
            if tonumber(score) > tonumber(highscores[currentLevel]) then
                highscores[currentLevel] = score
            end
            ball:update(dt)
            message = ""
            ball:touchWall()
            if ball:collidesPlatform(platform) then
                ball.dy = -ball.dy * 1.03
                if ball.dx < 0 then
                    ball.dx = -math.random(10, 150)
                else
                    ball.dx = math.random(10,150)
                end
                ball.y = platform.y - ball.radius - 2
            end
            if ball:collidesBricks(bricks) then
                ball.dy = -ball.dy
            end
            if newBall == 0 and ball.y >= VIRTUAL_HEIGHT then
                gameState = "done"
                message = "You lost... Press enter to restart."
                highscores[currentLevel] = initialHighscores[currentLevel]
            end
        
            if NUMBER_OF_BRICKS == 0 then
                gameState = "done"
                if not addedNewBallsPoints then
                    score = score + newBall * 200
                    addedNewBallsPoints = true
                end
                message = "You won with " .. score .. " points! Press enter to restart."
                if tonumber(score) > tonumber(initialHighscores[currentLevel]) then
                    highscores[currentLevel] = score
                    initialHighscores[currentLevel] = score
                    if currentLevel == 1 then
                        file = io.open("Atari-Breakout/highscore3.txt", "w")
                        file:write(score)
                        file:close()
                    elseif currentLevel == 2 then
                        file = io.open("Atari-Breakout/highscore4.txt", "w")
                        file:write(score)
                        file:close()
                    elseif currentLevel == 3 then
                        file = io.open("Atari-Breakout/highscore5.txt", "w")
                        file:write(score)
                        file:close()
                    elseif currentLevel == 4 then
                        file = io.open("Atari-Breakout/highscore6.txt", "w")
                        file:write(score)
                        file:close()
                    end
                end
            end
        end
    elseif gameState == "start" then
        message = "Press enter to start."
    end


end

function createChooseBalls()
    chooseBalls = {} 
    chooseBalls[1] = Ball(VIRTUAL_WIDTH*1/5-BALL_RADIUS, VIRTUAL_HEIGHT/5+15, BALL_RADIUS)
    chooseBalls[2] = Ball(VIRTUAL_WIDTH*2/5-BALL_RADIUS, VIRTUAL_HEIGHT/5+15, BALL_RADIUS)
    chooseBalls[3] = Ball(VIRTUAL_WIDTH*3/5-BALL_RADIUS, VIRTUAL_HEIGHT/5+15, BALL_RADIUS)
    chooseBalls[4] = Ball(VIRTUAL_WIDTH*4/5-BALL_RADIUS, VIRTUAL_HEIGHT/5+15, BALL_RADIUS)
    for i = 1, 4, 1
    do
        chooseBalls[i].dx = 0
        chooseBalls[i].dy = BALL_SPEED/5
    end
end

function chooseGameMode()
    message = "Choose your difficulty"
    for i = 1,4,1
    do
        chooseBalls[i]:render()
    end
    love.graphics.printf("Super easy", 0, VIRTUAL_HEIGHT/5, VIRTUAL_WIDTH*2/5, "center")
    love.graphics.printf("Easy", VIRTUAL_WIDTH*1/5, VIRTUAL_HEIGHT/5, VIRTUAL_WIDTH*2/5, "center")
    love.graphics.printf("Medium", VIRTUAL_WIDTH*1.5/5, VIRTUAL_HEIGHT/5, VIRTUAL_WIDTH*3/5, "center")
    love.graphics.printf("Hard", VIRTUAL_WIDTH*2/5, VIRTUAL_HEIGHT/5, VIRTUAL_WIDTH*4/5, "center")
end

function Game1:draw()
    push:apply("start")
    love.graphics.clear(20/255, 20/255, 20/255, 255/255)
    love.graphics.setColor({255, 255, 255})
    love.graphics.setFont(bigFont)
    love.graphics.printf("Atari Breakout", 0, 5, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT*2/3, VIRTUAL_WIDTH, "center")
    platform:render()
    Game1:displayFPS()
    if gameState == "choose" then
        chooseGameMode()
    else
        love.graphics.setColor({255,255,255})
        love.graphics.printf("New Ball(s): " .. newBall, 0, 20, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Score: " .. score, VIRTUAL_WIDTH*4/5, 10, VIRTUAL_WIDTH, "left")
        love.graphics.printf("Highscore: " .. highscores[currentLevel], VIRTUAL_WIDTH*4/5, 20, VIRTUAL_WIDTH, "left")
        love.graphics.print(mMessage, 10, 20)
        love.graphics.print(EnterMessage, 10, 30)
        ball:render()
        for i = 1,NUMBER_OF_BRICKS,1
        do
            bricks[i]:render()
        end
    end
    push:apply("end")
end

function Game1:displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function Game1:restart()
    addedAccelerator = false
    gameState = "choose"
    createChooseBalls()
    createdChooseBalls = false
    addedNewBallsPoints = false
    newBall = 3
    score = 0
    coeffecient = 1
    message = ""
    platform.x = (VIRTUAL_WIDTH - PLATFORM_WIDTH) / 2
    platform.y = VIRTUAL_HEIGHT - PLATFORM_HEIGHT - 20
    ball.x = VIRTUAL_WIDTH / 2
    ball.y = VIRTUAL_HEIGHT / 2
end

function semiReset()
    ball:reset()
    platform:reset()
    gameState = "start"
    coeffecient = 1
end

return Game1