utilFuncs = require "funcs"
Bomb = Object:extend()

function Bomb:new(x, y)
    self.image = love.graphics.newImage("sprites/bomb.png")
    self.x = x
    self.y = y
    self.speed = bombSpeed
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
end

function Bomb:update(dt)
    --move bomb down
    self.y = self.y + (self.speed + (level * 10)) * dt

    if self.y > love.graphics.getHeight() then
        --destroy the bullet
        self.offScreen = true
    end
end


function Bomb:checkCollision(obj)
    if utilFuncs.collided(self, obj)  then
        self.dead = true
    end
end

function Bomb:draw()
    love.graphics.draw(self.image, self.x, self.y)
end