currentGame = "none" -- none, first or second
startTime = 0

function love.load()
        loadMenu()
end

function loadMenu()
    Game1 = require("Atari-Breakout.main")
    Game2 = require("Switching-Ball.main")

    WINDOW_WIDTH = 1280
    WINDOW_HEIGHT = 720

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        resizable = false,
        fullscreen = false
    })
    love.window.setTitle("2D Games")

    smallFont = love.graphics.newFont("ShortBaby-Mg2w.ttf", 8)
    bigFont = love.graphics.newFont("ShortBaby-Mg2w.ttf", 90)
end

function love.keypressed(key)
    if currentGame == "none" then
        if key == "1" then
            currentGame = "first"
            Game1:load()
        elseif key == "2" then
            currentGame = "second"
            Game2:load()
        elseif key == "escape" then
            if startTime == 0 or os.time() > startTime + 1 then
                love.event.quit()
            end
        end
    elseif currentGame == "first" then
        Game1:keypressed(key)
    elseif currentGame == "second" then
        Game2:keypressed(key)
    end
end

function love.update(dt)
    if currentGame == "first" then
        Game1:update(dt)
    elseif currentGame == "second" then
        Game2:update(dt)
    end
end

function love.draw()
    if currentGame == "none" then
        love.graphics.setColor({1,1,1})
        love.graphics.setFont(bigFont)
        love.graphics.printf("2D Games", 0, 20, WINDOW_WIDTH, "center")
    elseif currentGame == "first" then
        Game1:draw()
    elseif currentGame == "second" then
        Game2:draw()
    end
end