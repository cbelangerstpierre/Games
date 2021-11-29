currentGame = "none" -- none, first or second or third
startTime = 0
numberOfGames = 3
musicOn = true
soundsOn = true

function love.load()
        loadMenu()
end

function loadMenu()
    Game1 = require("Atari-Breakout.main")
    Game2 = require("Switching-Ball.main")
    Game3 = require("Defender.main")
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

    imgs = {
        [1] = Image("imgs/Game1.png", 640, 360),
        [2] = Image("imgs/Game2.png", 640, 360),
        [3] = Image("imgs/Game3.png", 360, 360)
    }

    smallFont = love.graphics.newFont("fonts/ShortBaby-Mg2w.ttf", 8)
    bigFont = love.graphics.newFont("fonts/ShortBaby-Mg2w.ttf", 90)

    if musicOn then
        sounds['music']:play()
        sounds['music']:setLooping(true)
    end
end

function love.keypressed(key)
    if currentGame == "none" then
        if key == "enter" or key == "return" then
            if currentImage == 1 then
                love.audio.stop()
                currentGame = "first"
                Game1:load()
            elseif currentImage == 2 then
                love.audio.stop()
                currentGame = "second"
                Game2:load()
            elseif currentImage == 3 then
                love.audio.stop()
                currentGame = "third"
                Game3:load()
            end
        elseif key == "escape" and (startTime == 0 or os.time() > startTime + 1) then
            love.event.quit()
        elseif key == "right" or key == "d" then
            if currentImage < numberOfGames then
                currentImage = currentImage + 1
            else
                currentImage = 1
            end
        elseif key == "left" or key == "a" then
            if currentImage > 1 then
                currentImage = currentImage - 1
            else
                currentImage = numberOfGames
            end
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
    elseif currentGame == "first" then
        Game1:keypressed(key)
    elseif currentGame == "second" then
        Game2:keypressed(key)
    elseif currentGame == "third" then
        Game3:keypressed(key)
    end
end

function love.update(dt)
    if currentGame == "first" then
        Game1:update(dt)
    elseif currentGame == "second" then
        Game2:update(dt)
    elseif currentGame == "third" then
        Game3:update(dt)
    end
end

function love.draw()
    if currentGame == "none" then
        love.graphics.setColor({1,1,1})
        love.graphics.setFont(bigFont)
        love.graphics.printf("2D Games", 0, 20, WINDOW_WIDTH, "center")
        imgs[currentImage]:render()

    elseif currentGame == "first" then
        Game1:draw()
    elseif currentGame == "second" then
        Game2:draw()
    elseif currentGame == "third" then
        Game3:draw()
    end
end