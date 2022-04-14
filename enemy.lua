Enemy = Object:extend()

function Enemy:new(Y)
    self.image = love.graphics.newImage("sprites/Invader.png")
    self.x = love.math.random(20, love.graphics.getWidth()-20)
    self.y = Y
    self.speed = enemySpeed + love.math.random(1, 25)
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.shot = false

    --create a quad to store the animated gif frames in the spritesheet (2 frames)
    quads = {}
	local spriteHeight = self.height / 2
	for i=0,1 do
		table.insert(quads, love.graphics.newQuad(0, i * spriteHeight, self.width, self.height/2, self.image:getDimensions()))
	end
    timer=0
end

function Enemy:update(dt)
    --if it's been shot then do not move the alien
    if self.shot then
        return
    end
    --move enemy
    self.x = self.x + self.speed * dt

    --check if we hit edge of window
    local window_width = love.graphics.getWidth()

    if self.x < 0 then
        self.x=0
        self.speed = -self.speed --reverse direction
    elseif self.x + self.width > window_width then
        self.x = window_width-self.width
        self.speed = -self.speed --reverse direction
    end
    --timer is for the spritesheet for which frame is displayed
    timer = timer + dt * self.speed

    --randomly launch a bomb
    if love.math.random(1,500-(level * 10)) == 50 then
        table.insert(listOfBombs, Bomb(self.x + (self.width/2), self.y + (self.height /2)))
    end
end

function Enemy:draw()
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
