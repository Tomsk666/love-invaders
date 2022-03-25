--Invaders game by Tom Millichamp March 2022

function love.load()
    --uses 'classic' library that emulates object classes from https://github.com/rxi/classic
    Object=require "libs/classic"

    require "player"
    require "enemy"
    require "bullet"
    require "bomb"

    score = 0
    lives = 3
    playerDead=false
    level = 1
    enemySpeed = 50

    listOfBullets = {} -- create a table (array) to store bullet objects
    listOfBombs = {} -- for alien bombs
    listOfEnemies = {} -- store invaders
    table.insert(listOfEnemies, Enemy(50))
    player = Player()
    --enemy = Enemy()

    startScreen = true
end

function love.update(dt)
    if gamePaused or playerDead or startScreen then
        return
    end

    player:update(dt)

    for n,e in ipairs (listOfEnemies) do
        --enemy:update(dt)
        e:update(dt)

        --update bullets player fires
        for i, v in ipairs (listOfBullets) do
            v:update(dt)
            v:checkCollision(e)
            if v.dead then
                table.remove(listOfBullets,i)
                score = score + 1
                --enemy.image=love.graphics.newImage("sprites/explosion.png")
                
                --draw an explosion
                love.graphics.clear()
                e.image=love.graphics.newImage("sprites/explosion.png")
                e:draw()
                love.graphics.present()
                local start = os.time()
                repeat until os.time() > start + 0.5
                e.image=love.graphics.newImage("sprites/Invader.png")
                
                --remove the enemy shot
                table.remove(listOfEnemies, n)
                --check if we killed them all
                if next(listOfEnemies) == nil then
                    -- no more enemies!
                    levelUp()
                    return
                 end
                
            end
            if v.offScreen then
                table.remove(listOfBullets,i)
            end
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
    if startScreen then
        -- Display Start screen with instructions
        love.graphics.print("Alien Invaders!!!", love.graphics.getWidth() / 2 -150, love.graphics.getHeight() / 3)
        love.graphics.print("Arrow keys - Left & Right", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +20)
        love.graphics.print("Space bar - Shooot", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +40)
        love.graphics.print("Escape - Quit", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +60)
        love.graphics.print("Click Off/On Screen to Pause", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +80)
        love.graphics.print("Press ENTER to Start...", love.graphics.getWidth() / 2 -150, (love.graphics.getHeight() / 3) +120)
        return
    elseif gamePaused then
        love.graphics.print("PAUSED", love.graphics.getWidth() / 2 -50, love.graphics.getHeight() / 3)
        return
    elseif playerDead then
        love.graphics.print("GAME OVER!!", love.graphics.getWidth() / 2 -100, love.graphics.getHeight() / 3)
        love.graphics.print("You Scored : " .. score, love.graphics.getWidth() / 2 -100, (love.graphics.getHeight() / 3) +20)
        love.graphics.print("Press 's' to play again", love.graphics.getWidth() / 2 -100, (love.graphics.getHeight() / 3) +60)
        love.graphics.print("or 'escape' to Quit", love.graphics.getWidth() / 2 -100, (love.graphics.getHeight() / 3) +80)
        return
    end

    love.graphics.print("Score: " .. score, 20, 20) -- .. is string concatenation!
    love.graphics.print("Lives: " .. lives, love.graphics.getWidth()-70, 20)
    player:draw()
    for n, e in ipairs (listOfEnemies) do
        e:draw()
    end
    --enemy:draw()
    for i, v in ipairs (listOfBullets) do
        v:draw(dt)
    end
    for i, v in ipairs (listOfBombs) do
        v:draw(dt)
    end
end

--check if player presses any keys
--this gets invoked on a keypress event
function love.keypressed(key)
    if key == "space" then
        player:keyPressed(key)
    elseif key == "escape" then
        love.event.quit()
    elseif key == "s" then 
        --restart game
        love.load()
    elseif key == "return" then 
        --start game
        startScreen = false
    end
end

--check if player has moved to another application window
function love.focus(f)
    gamePaused = not f
end


--function for when you clear all aliens on a level
function levelUp()
    level = level + 1
    --lets speed them up!
    enemySpeed = enemySpeed + (level * 5)
    --remove all existng aliens
    for k,v in pairs(listOfEnemies) do
        listOfEnemies[k] = nil
    end
      --create new ones (number of aliens depending on level)
    for i = 1, level do
        table.insert (listOfEnemies, Enemy(50 + (25 * i)))
    end
    love.graphics.clear()
    love.graphics.print("LEVEL : " .. level, love.graphics.getWidth() / 2 -50, love.graphics.getHeight() / 3)
    love.graphics.present()
    local start = os.time()
    repeat until os.time() > start + 1.5
end

