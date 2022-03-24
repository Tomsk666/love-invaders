--Invaders game by Tom Millichamp March 2022

function love.load()
    --uses 'classic' library that emulates object classes from https://github.com/rxi/classic
    Object=require "libs/classic"

    require "player"
    require "enemy"
    require "bullet"
    require "bomb"

    player = Player()
    enemy = Enemy()
    listOfBullets = {} -- create a table (array) to store bullet objects
    listOfBombs = {} -- for alien bombs
    score = 0
    lives = 3
    playerDead=false

    local lastKey=null
end

function love.update(dt)
    if gamePaused then
        return
    end

    player:update(dt)
    enemy:update(dt)

    --update bullets player fires
    for i, v in ipairs (listOfBullets) do
        v:update(dt)
        v:checkCollision(enemy)
        if v.dead then
            table.remove(listOfBullets,i)
            score = score + 1
            enemy.image=love.graphics.newImage("sprites/explosion.png")
        end
        if v.offScreen then
            table.remove(listOfBullets,i)
        end
    end

    --update bombs aliens drop
    for i, v in ipairs (listOfBombs) do
        v:update(dt)
        v:checkCollision(player)
        if v.dead then
            table.remove(listOfBombs,i)
            lives = lives - 1
            --draw the player dead (bang.png)
            love.graphics.clear()
            player.image=love.graphics.newImage("sprites/bang.png")
            player:draw()
            love.graphics.present()
            local start = os.time()
            repeat until os.time() > start + 0.5
            player.image = love.graphics.newImage("sprites/canon.png")
            if lives == 0 then
                playerDead=true
            end
        end
        if v.offScreen then
            table.remove(listOfBombs,i)
        end
    end
end

function love.draw()
    if gamePaused then
        love.graphics.print("PAUSED", love.graphics.getWidth() / 2 -50, love.graphics.getHeight() / 2)
        return
    end
    if playerDead then
        love.graphics.print("GAME OVER!!", love.graphics.getWidth() / 2 -50, love.graphics.getHeight() / 2)
        love.graphics.print("Press 's' to play again", love.graphics.getWidth() / 2 -50, (love.graphics.getHeight() / 2) +20)
        love.graphics.print("or 'escape' to Quit", love.graphics.getWidth() / 2 -50, (love.graphics.getHeight() / 2) +40)
        if lastKey == "s" then 
            love.load()
        end
        return
    end

    love.graphics.print("Score: " .. score, 20, 20) -- .. is string concatenation!
    love.graphics.print("Lives: " .. lives, love.graphics.getWidth()-70, 20)
    player:draw()
    enemy:draw()
    for i, v in ipairs (listOfBullets) do
        v:draw(dt)
    end
    for i, v in ipairs (listOfBombs) do
        v:draw(dt)
    end
end

--check if player fires missile
function love.keypressed(key)
    lastKey=key
    player:keyPressed(key)
end

--check if player has moved to another application window
function love.focus(f)
    gamePaused = not f
end