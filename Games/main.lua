currentGame = 0
startTime = 0
numberOfGames = 4
musicOn = true
soundsOn = true

function love.load()
    Games = {
        [1] = require("Atari-Breakout.main"),
        [2] = require("Switching-Ball.main"),
        [3] = require("Defender.main"),
        [4] = require("Othello.main")
    }
    loadMenu()
end

function loadMenu()

    Class = require("class")
    Image = require("Image")

    WINDOW_WIDTH = 1280
    WINDOW_HEIGHT = 720
    currentImage = 1

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        resizable = false,
        fullscreen = false
    })
    love.window.setTitle("2D Games")

    sounds = {
        ['music'] = love.audio.newSource("sounds/music.mp3", "static")
    }

    gamesImgs = {
        [1] = Image("imgs/Game1.png", 640, 360, (WINDOW_WIDTH - 640)/2, (WINDOW_HEIGHT - 360)/2, 0),
        [2] = Image("imgs/Game2.png", 640, 360, (WINDOW_WIDTH - 640)/2, (WINDOW_HEIGHT - 360)/2, 0),
        [3] = Image("imgs/Game3.png", 360, 360, (WINDOW_WIDTH - 360)/2, (WINDOW_HEIGHT - 360)/2, 0),
        [4] = Image("imgs/Game4.png", 360, 360, (WINDOW_WIDTH - 360)/2, (WINDOW_HEIGHT - 360)/2, 0)
    }

    arrowImgs = {
        [1] = Image("imgs/arrow.png", 50, 50, 0, 0, 0),
        [2] = Image("imgs/arrow.png", 50, 50, 0, 0, math.rad(180))
    }

    adjustArrows()

    smallFont = love.graphics.newFont("fonts/ShortBaby-Mg2w.ttf", 8)
    bigFont = love.graphics.newFont("fonts/ShortBaby-Mg2w.ttf", 90)

    if musicOn then
        sounds['music']:play()
        sounds['music']:setLooping(true)
    end
end

function adjustArrows()
    arrowImgs[1].x = gamesImgs[currentImage].x - arrowImgs[1].width - 50
    arrowImgs[1].y = gamesImgs[currentImage].y + (gamesImgs[currentImage].height - arrowImgs[1].height) /2
    arrowImgs[2].x = gamesImgs[currentImage].x + gamesImgs[currentImage].width + arrowImgs[2].width + 50
    arrowImgs[2].y = gamesImgs[currentImage].y + (gamesImgs[currentImage].height + arrowImgs[1].height) /2
end

function love.mousepressed(x, y, button, istouch, presses)
    if currentGame == 0 and button == 1 then
        if isBetween(x, arrowImgs[1].x, arrowImgs[1].x + arrowImgs[1].width)
        and isBetween(y, arrowImgs[1].y, arrowImgs[1].y + arrowImgs[1].height) then
            changeImage("left")
        elseif isBetween(x, arrowImgs[2].x, arrowImgs[2].x - arrowImgs[2].width)
        and isBetween(y, arrowImgs[2].y, arrowImgs[2].y - arrowImgs[2].height) then
            changeImage("right")
        end
    elseif currentGame == 4 then
        Game4:mousepressed(x, y, button, istouch, presses)
    end
end

function changeImage(side)
    if side == "right" then
        if currentImage < numberOfGames then
            currentImage = currentImage + 1
        else
            currentImage = 1
        end
    else
        if currentImage > 1 then
            currentImage = currentImage - 1
        else
            currentImage = numberOfGames
        end
    end
    adjustArrows()
end

function love.keypressed(key)
    if currentGame == 0 then
        if key == "enter" or key == "return" then
            love.audio.stop()
            currentGame = currentImage
            Games[currentGame]:load()
        elseif key == "escape" and (startTime == 0 or os.time() > startTime + 1) then
            love.event.quit()
        elseif key == "right" or key == "d" then
            changeImage("right")
        elseif key == "left" or key == "a" then
            changeImage("left")
        elseif key == "m" then
            if musicOn then
                love.audio.stop()
                musicOn = false
            else
                sounds['music']:play()
                sounds['music']:setLooping(true)
                musicOn = true
            end
        end
    else
        Games[currentGame]:keypressed(key)
    end
end

function love.update(dt)
    if not (currentGame == 0) then
        Games[currentGame]:update(dt)
    end
end

function love.draw()
    if currentGame == 0 then
        love.graphics.setColor({1,1,1})
        love.graphics.setFont(bigFont)
        love.graphics.printf("2D Games", 0, 20, WINDOW_WIDTH, "center")
        gamesImgs[currentImage]:render()
        gamesImgs[currentImage]:lineRender()
        for i = 1,2,1 do
            arrowImgs[i]:render()
        end
    else
        Games[currentGame]:draw()
    end
end

function isBetween(a, b, c)
    if (b <= a and a <= c) or (c <= a and a <= b) then
        return true
    else
        return false
    end
end