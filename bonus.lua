--This is for the bonus red invader that sometimes shoots across the screen
Bonus = Object:extend()

function Bonus:new()
    self.image = love.graphics.newImage("sprites/Invader_red.png")
    self.x = 0
    self.y = love.math.random(50, 300)
    self.speed = enemySpeed + love.math.random(50, 100)
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.shot=false

    --create a quad to store the animated gif frames in the spritesheet (2 frames)
    quads = {}
	local spriteHeight = self.height / 2
	for i=0,1 do
		table.insert(quads, love.graphics.newQuad(0, i * spriteHeight, self.width, self.height/2, self.image:getDimensions()))
	end
    timer=0
end

function Bonus:update(dt)
    if self.shot then 
        return
    end
    --move enemy
    self.x = self.x + self.speed * dt

    --check if we hit edge of window
    if self.x > love.graphics.getWidth() - self.width then
        bonusInPlay = false
    end
    --timer is for the spritesheet for which frame is displayed
    timer = timer + dt * self.speed
end

function Bonus:draw()
    --if it's shot then draw an explosion instead of alien
    if self.shot then
        self.image = love.graphics.newImage("sprites/bang.png")
        love.graphics.draw(self.image, self.x, self.y)
        return
    end
    --love.graphics.draw(self.image, self.x, self.y)
    --display alternating frames from quad spritesheet
    love.graphics.draw(self.image, quads[(math.floor(timer) % 2) + 1], self.x, self.y)
end
