--class name should be same as filenmae

Player=Object:extend()

function Player:new()
    self.image = love.graphics.newImage("sprites/canon.png")
    --self.image = love.graphics.newImage("panda.png")
    self.x = love.graphics.getWidth() / 2
    self.y = love.graphics.getHeight() - self.image:getHeight() - 10
    self.speed = 500
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Player:update(dt)
    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
    end

    --check for edge of screen
    local window_width = love.graphics.getWidth()
    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > window_width then
        self.x = window_width - self.width
    end
end

function Player:keyPressed(key)
    if key == "space" then
        table.insert(listOfBullets, Bullet(self.x + (self.width/2), self.y))
    elseif key=="escape" then
        love.event.quit()
    end
end

function Player:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
