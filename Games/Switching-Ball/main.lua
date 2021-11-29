Game2 = {}

function Game2:load()
    Image = require("Switching-Ball.Image")
    Ball = require("Switching-Ball.Ball")
    
    WINDOW_WIDTH = 1280
    WINDOW_HEIGHT = 720
    CIRCLE_RADIUS = 200
    CIRCLE_X = WINDOW_WIDTH/2 - CIRCLE_RADIUS
    CIRCLE_Y = (WINDOW_HEIGHT-400)/2+20
    MID_CIRCLE_X = WINDOW_WIDTH/2
    MID_CIRCLE_Y = CIRCLE_Y + CIRCLE_RADIUS
    CIRCLE_FILE = "Switching-Ball/Circle.png"
    CIRCLE_BORDER = 31
    RECTANGLE_WIDTH = 25
    RECTANGLE_HEIGHT = 73
    RECTANGLE_FILE = "Switching-Ball/Rectangle.png"
    BALL_RADIUS = 15
    BALL_SPEED = 75
    gameState = "start"
    currentRectangleOrientation = 0
    message = "Enter to start"
    score = 0
    lastScore = 0
    colors = {}

    sounds = {
        ['music'] = love.audio.newSource("Switching-Ball/sounds/music.mp3", "static"),
        ['lose'] = love.audio.newSource("Switching-Ball/sounds/lose.mp3", 'static')
    }

    sounds['music']:setVolume(0.4)
    sounds['lose']:setVolume(0.7)

---@diagnostic disable-next-line: discard-returns
    math.randomseed(os.time())

    file = io.open("/home/cedric/LuaProjects/Mine/Games/Switching-Ball/Highscore.txt", "r")
    highscore = file:read("*all")
    file:close()

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        resizable = false,
        fullscreen = false
    })
    love.window.setTitle("Switching Ball")

    bigFont = love.graphics.newFont("Switching-Ball/BelieveIt-DvLE.ttf", 84)
    smallFont  = love.graphics.newFont("Switching-Ball/ArianaVioleta-dz2K.ttf", 40)

    circle = Image(CIRCLE_FILE, CIRCLE_X, CIRCLE_Y, CIRCLE_RADIUS*2, CIRCLE_RADIUS*2, 0, "static", {20/255,20/255,20/255})
    rectangles = {}

    
    currentRectangleOrientation = currentRectangleOrientation + math.random(50, 90)

    rectangles[1] = createRectangle(currentRectangleOrientation, {224/255, 49/255, 49/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
    rectangles[2] = createRectangle(currentRectangleOrientation, {80/255, 93/255, 191/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
    rectangles[3] = createRectangle(currentRectangleOrientation, {73/255, 191/255, 69/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
    rectangles[4] = createRectangle(currentRectangleOrientation, {217/255, 179/255, 76/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)

    ball = Ball(
        WINDOW_WIDTH/2,
        CIRCLE_Y-BALL_RADIUS,
        BALL_RADIUS,
        0,
        BALL_SPEED)
    
    colors[1] = {255, 0, 0}
    colors[2] = {0, 0, 255}
end
    

function createRectangle(orientation, color)
    if math.random(1,2) == 2 then
        num = -1
        border_adjuster = 0
        state = "outside"
    else
        num = 1
        border_adjuster = CIRCLE_BORDER
        state = "inside"
    end
    return Image(
    RECTANGLE_FILE,
    MID_CIRCLE_X+(CIRCLE_RADIUS+2*num-border_adjuster)*math.sin(math.rad(orientation))-RECTANGLE_WIDTH/2*math.cos(math.rad(orientation)),
    MID_CIRCLE_Y-(CIRCLE_RADIUS+2*num-border_adjuster)*math.cos(math.rad(orientation))-RECTANGLE_WIDTH/2*math.sin(math.rad(orientation)),
    RECTANGLE_WIDTH,
    RECTANGLE_HEIGHT*num,
    math.rad(orientation % 360),
    state,
    color
)
end

function Game2:keypressed(key)
    if key == "escape" then
        startTime = os.time()
        love.audio.stop()
        currentGame = "none"
        loadMenu()
    elseif key == "enter" or key == "return" or key == "space" then
        if gameState == "start" then
            gameState = "play"
            message = ""
            if musicOn then
                sounds['music']:play()
                sounds['music']:setLooping(true)
            end
        elseif gameState == "play" then
            if ball.state == "outside" then
                ball.border_adjuster = CIRCLE_BORDER
                ball.state = "inside"
            else
                ball.border_adjuster = 0
                ball.state = "outside"
            end
        elseif gameState == "done" then
            Game2:restart()
        end
    elseif key == "p" then
        if gameState == "play" then
            gameState = "paused"
            message = "Paused"
        elseif gameState == "paused" then
            gameState = "play"
            message = ""
        end
    elseif key == "m" then
        if not soundsOn then
            sounds['music']:play()
            sounds['music']:setLooping(true)
            musicOn = true
            soundsOn = true
        elseif not musicOn then
            soundsOn = false
        else
            love.audio.stop(sounds['music'])
            musicOn = false
        end
    end
end

function Game2:update(dt)
    if gameState == "play" then
        ball:update(dt)
        if ball:touchRectangle(rectangles) then
            love.audio.stop()
            if soundsOn then
                sounds['lose']:play()
            end
            gameState = "done"
            message = "Enter to restart"
            lastScore = score
            if score == highscore then
                file = io.open("/home/cedric/LuaProjects/Mine/Games/Switching-Ball/Highscore.txt", "w")
                file:write(score)
                file:close()
            end
        end
        for i = 1,tablelength(rectangles), 1 
        do
            if (ball.orientation - math.deg(rectangles[i].orientation) >= 20 and 
            ball.orientation - math.deg(rectangles[i].orientation) <= 40) or
            ((ball.orientation+360 - math.deg(rectangles[i].orientation) >= 20 and 
            ball.orientation+360 - math.deg(rectangles[i].orientation) <= 40))
            then
                score = score + 1
                if score > tonumber(highscore) then
                    highscore = score
                end
                rectangles[i] = createRectangle(currentRectangleOrientation, rectangles[i].color)
                currentRectangleOrientation = currentRectangleOrientation + math.random(20, 90)
            end    
        end
    end
end

function Game2:draw()
    love.graphics.clear(0/255, 107/255, 95/255, 1/255)
    Game2:displayFPS()
    ball:render()
    
    for i = 1,tablelength(rectangles),1
    do
        rectangles[i]:render()
    end
    love.graphics.setColor({1, 1, 1})
    love.graphics.setFont(bigFont)
    love.graphics.printf("Rotating Ball", 0, CIRCLE_Y-RECTANGLE_HEIGHT-bigFont.getHeight(bigFont)-10, WINDOW_WIDTH, "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf("score: " .. score, WINDOW_WIDTH*5/6, 20, WINDOW_WIDTH, "left")
    love.graphics.printf("highscore: " .. highscore, WINDOW_WIDTH*5/6, 55, WINDOW_WIDTH, "left")
    love.graphics.printf("last score : " .. lastScore, WINDOW_WIDTH*5/6, 90, WINDOW_WIDTH, "left")
    love.graphics.printf(message, 0, MID_CIRCLE_Y-20, WINDOW_WIDTH, "center")
    circle:render()
end

function Game2:displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 20)
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function xor(a,b)
    return (a or b) and not (a and b)
end

function Game2:restart()
    ball.state = "outside"
    gameState = "start"
    message = "Enter to start"
    score = 0
    ball.x = WINDOW_WIDTH/2
    ball.y = CIRCLE_Y-BALL_RADIUS
    ball.border_adjuster = 0

    ball.orientation = 0
    
    currentRectangleOrientation = math.random(50, 90)

    rectangles[1] = createRectangle(currentRectangleOrientation, {224/255, 49/255, 49/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
    rectangles[2] = createRectangle(currentRectangleOrientation, {80/255, 93/255, 191/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
    rectangles[3] = createRectangle(currentRectangleOrientation, {73/255, 191/255, 69/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
    rectangles[4] = createRectangle(currentRectangleOrientation, {217/255, 179/255, 76/255})
    currentRectangleOrientation = currentRectangleOrientation + math.random(20, 80)
end

return Game2