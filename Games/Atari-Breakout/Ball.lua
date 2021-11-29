local Ball = Class{}

function Ball:init(x, y, radius)
    self.x = x
    self.y = y
    self.radius = radius
    self.dy = BALL_SPEED
    if math.random(-1, 1) < 0 then
        self.dx = math.random(-BALL_SPEED/2, -BALL_SPEED/4)
    else
        self.dx = math.random(BALL_SPEED/2, BALL_SPEED/4)
    end
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:collidesPlatform(platform)
    if self.x > platform.x + platform.width or platform.x > self.x + self.radius * 2 then
        return false
    end
    if self.y > platform.y + platform.height or platform.y > self.y + self.radius * 2 then
        return false
    end
    if soundsOn then
        sounds['platform_hit']:play()
    end
    return true
end

function Ball:collidesBricks(bricks)
    for i = 1,NUMBER_OF_BRICKS,1
    do
        if not (self.x > bricks[i].x + bricks[i].width or bricks[i].x > self.x + self.radius * 2) and not 
        (self.y > bricks[i].y + bricks[i].height or bricks[i].y > self.y + self.radius * 2) then
            table.remove(bricks, i)
            NUMBER_OF_BRICKS = NUMBER_OF_BRICKS - 1
            score = score + coeffecient
            coeffecient = coeffecient + 1
            if soundsOn then
                sounds['score']:play()
            end
            return true
        end
    end
end    

function Ball:touchWall()
    --below
    if self.y >= VIRTUAL_HEIGHT then
        if soundsOn then
            sounds['lose']:play()
        end
        semiReset()
    --above
    elseif self.y <= 0 then
        self.y = self.y + self.radius * 2
        self.dy = -self.dy
        if soundsOn then
            sounds['wall_hit']:play()
        end
    --left
    elseif self.x <= 0 then
        self.x = self.x + self.radius * 2
        self.dx = -self.dx
        if soundsOn then
            sounds['wall_hit']:play()
        end
    --right
    elseif self.x >= VIRTUAL_WIDTH then
        self.x = self.x - self.radius * 2
        self.dx = -self.dx
        if soundsOn then
            sounds['wall_hit']:play()
        end
    end
end

function Ball:reset()
    if newBall > 0 then
        self.x = VIRTUAL_WIDTH / 2
        self.y = VIRTUAL_HEIGHT / 2
        self.dy = BALL_SPEED
        if math.random(-1, 1) < 0 then
            self.dx = math.random(-BALL_SPEED/2, -BALL_SPEED/4)
        else
            self.dx = math.random(BALL_SPEED/2, BALL_SPEED/4)
        end
    end
end

function Ball:render()
    love.graphics.setColor({1, 1, 1})
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Ball