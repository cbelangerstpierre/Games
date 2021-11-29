Heart = Class{}

function Heart:init(file, x, y, width, height)
    self.image = love.graphics.newImage(file)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.widthRatio = self.width/self.image.getWidth(self.image)
    self.heightRatio = self.height/self.image.getHeight(self.image)
end

function Heart:render()
    love.graphics.setColor({1, 1, 1})
    love.graphics.draw(self.image, self.x, self.y, 0, self.widthRatio, self.heightRatio)
end

function Heart:touchFireball(fireballs, hearts)
    for i = tablelength(fireballs), 1, -1 do
        if (WINDOW_WIDTH/2 <= fireballs[i].x + fireballs[i].width * math.cos(math.rad(fireballs[i].orientation)) and
            WINDOW_WIDTH/2 >= fireballs[i].x) or
            (WINDOW_WIDTH/2 >= fireballs[i].x + fireballs[i].width * math.cos(math.rad(fireballs[i].orientation)) and
            WINDOW_WIDTH/2 <= fireballs[i].x) or
            (WINDOW_HEIGHT/2 <= fireballs[i].y + fireballs[i].width * math.sin(math.rad(fireballs[i].orientation)) and
            WINDOW_HEIGHT/2 >= fireballs[i].y) or
            (WINDOW_HEIGHT/2 >= fireballs[i].y + fireballs[i].width * math.sin(math.rad(fireballs[i].orientation)) and
            WINDOW_HEIGHT/2 <= fireballs[i].y) then
            table.remove(fireballs, i)
            numberOfHearts = numberOfHearts - 1
            heartPosUpdate()
            if soundsOn then
                sounds["lose"]:clone():play()
            end
        end
    end
end