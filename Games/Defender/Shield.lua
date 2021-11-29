Shield = Class{}

function Shield:init(file, x, y, width, height, orientation)
    self.image = love.graphics.newImage(file)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.widthRatio = self.width/self.image.getWidth(self.image)
    self.heightRatio = self.height/self.image.getHeight(self.image)
    self.orientation = orientation
end

function Shield:render()
    love.graphics.setColor({1, 1, 1})
    love.graphics.draw(self.image, self.x, self.y, math.rad(self.orientation), self.widthRatio, self.heightRatio)
end

function Shield:update()
    self.x = WINDOW_WIDTH/2 + SHIELD_HEIGHT/2 * math.sin(math.rad(self.orientation)) + 30 * math.cos(math.rad(self.orientation))
    self.y = WINDOW_HEIGHT/2 -SHIELD_HEIGHT/2 * math.cos(math.rad(self.orientation)) + 30 * math.sin(math.rad(self.orientation))
end

function Shield:touchFireball(fireballs)
    for i = tablelength(fireballs), 1, -1
    do
        if math.abs(self.orientation - fireballs[i].orientation) == 180 then
            if (self.x + self.width * math.cos(math.rad(self.orientation)) <= fireballs[i].x + fireballs[i].width * math.cos(math.rad(fireballs[i].orientation)) and
            self.x + self.width * math.cos(math.rad(self.orientation)) >= fireballs[i].x) or
            (self.x + self.width * math.cos(math.rad(self.orientation)) >= fireballs[i].x + fireballs[i].width * math.cos(math.rad(fireballs[i].orientation)) and
            self.x + self.width * math.cos(math.rad(self.orientation)) <= fireballs[i].x) or
            (self.y + self.width *  math.sin(math.rad(self.orientation)) <= fireballs[i].y + fireballs[i].width * math.sin(math.rad(fireballs[i].orientation)) and
            self.y + self.width *  math.sin(math.rad(self.orientation)) >= fireballs[i].y) or
            (self.y + self.width *  math.sin(math.rad(self.orientation)) >= fireballs[i].y + fireballs[i].width * math.sin(math.rad(fireballs[i].orientation)) and
            self.y + self.width *  math.sin(math.rad(self.orientation)) <= fireballs[i].y) then
                    
                table.remove(fireballs, i)
                if soundsOn then
                    sounds["hit"]:clone():play()
                end
            end
        end
    end
end