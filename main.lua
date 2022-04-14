--Alien Invaders game by Tom Millichamp March 2022

--uncomment for debugging:
--if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then 
--    require("lldebugger").start() 
--end 

--set window size
view_w = 800
view_h = 600
background = {}
background.image = love.graphics.newImage("sprites/background.png")
background.x = 0
background.y = -600

alien_dead_snd = love.audio.newSource("snd/alien_dead.ogg", "static")
bonus_ship_snd = love.audio.newSource("snd/bonus_ship.ogg", "static")
player_dead_snd = love.audio.newSource("snd/player_dead.ogg", "static")
player_shoot_snd = love.audio.newSource("snd/player_shoot.ogg", "static")
big_bonus_snd = love.audio.newSource("snd/big_bonus.ogg", "static")

arkham_font = "fonts/Arkham_bold.TTF"

--for high scores saving
highscore = require "libs/sick"

--uses 'classic' library that emulates object classes from https://github.com/rxi/classic
Object = require "libs/classic"

local utf8 = require "utf8"

function love.load()
    --set window size, title & background
    love.window.setMode (view_w, view_h,{resizable=false,vsync=false})
    love.window.setTitle("Alien Invaders by Tom Millichamp")

    --play our intro theme
    intro= love.audio.newSource("snd/intro.ogg", "stream")
    intro:setLooping(true)
    love.audio.play(intro)

    require "player"
    require "enemy"
    require "bullet"
    require "bomb"
    require "bonus"

    score = 0
    lives = 3
    playerDead=false
    level = 1
    enemySpeed = 35
    bombSpeed = 400
    bonusInPlay = false
    bigBonus = 0
    bigBonusText = {"B","BO","BON","BONU","BONUS"}
    clock=0

    listOfBullets = {} -- create a table (array) to store bullet objects
    listOfBombs = {} -- for alien bombs
    listOfEnemies = {} -- store invaders

    --create 1 alien & our player
    --when we create an enemy, we pass in the Y co-ordinate for how far down the screen it appears
    table.insert(listOfEnemies, Enemy(45))
    player = Player()

    --set up the high scores file
    highscore.set("scores")

    --set up a string to capture players name
    playerName = ""
    love.event.clear()
    love.keyboard.setKeyRepeat(true)

    --go to the start screen
    startScreen = true
end

function love.update(dt)
    clock = clock + dt

    --only update if in play
    if gamePaused or playerDead or startScreen then
        return
    end

    --update scrolling background
    if background.y < 0 then
        background.y = background.y + (dt * 15)
    else
        background.y = -600
    end

    --update player
    player:update(dt)

    --update the bonus alien (red alien) if it is on-screen
    if bonusInPlay then
        bonus:update(dt)
    else
        --if it isn't then create one at random, but only from level 3 onwards
        bonus = nil
        if love.math.random(1,2500) == 73 and level > 2 then
            --create a new bonus alien
            bonus = Bonus()
            bonusInPlay = true
            love.audio.play(bonus_ship_snd)
        end
    end

    --update our table of alien enemies
    --on each iteration, check if we hit one with our bullets
    for n,e in ipairs (listOfEnemies) do
        if e.shot and clock > 1 then
            table.remove(listOfEnemies, n)
            --if next(listOfEnemies) == nil then
            if #listOfEnemies == 0 then
                -- no more enemies! so Level up!
                levelUp()
                return
            end
        end

        --move enemy
        e:update(dt)

        --update bullets player fires
        for i, v in ipairs (listOfBullets) do
            --move the bullet
            v:update(dt)

            --check if bullet hit enemy
            v:checkCollision(e)
            if v.dead then
                love.audio.play(alien_dead_snd)
                table.remove(listOfBullets,i)
                score = score + 10
                --mark the alien as shot
                e.shot = true    
                break  
            end
            --check if bullet hit bonus
            if bonusInPlay and not v.dead and not bonus.shot then
                v:checkCollision(bonus)
                if v.dead then
                    love.audio.play(alien_dead_snd)
                    table.remove(listOfBullets,i)
                    score=score + 50
                    --update the big bonus where if you hit 5 bonus aliens you get 
                    --the word bonus at top of screen & score and extra 100
                    bonus.shot=true
                    bigBonus=bigBonus+1
                    if bigBonus == 5 then
                        love.audio.play(big_bonus_snd)
                        score = score + 150
                        bigBonus = 0
                        if level > 5 then
                            lives = lives + 1
                        end
                        love.graphics.setNewFont(arkham_font, 24)
                        love.graphics.clear()
                        strText = "B O N U S !!!"
                        if level > 5 then
                            strText = "B O N U S !!!\n EXTRA LIFE!!"
                        end
                        love.graphics.printf(strText, 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
                        love.graphics.present()
                        local start = os.time()
                        repeat until os.time() > start + 0.05
                        love.graphics.setNewFont(12)
                    end
                    break
                end
            end

            --check if bullet has gone off-screen
            if v.offScreen then
                table.remove(listOfBullets,i)
            end
        end
    end

    

    --update bombs aliens drop
    --and check if they hit the player
    for i, v in ipairs (listOfBombs) do
        v:update(dt)
        v:checkCollision(player)
        if v.dead then
            love.audio.play(player_dead_snd)
            table.remove(listOfBombs,i)
            lives = lives - 1
            --draw the player dead (bang.png)
            love.graphics.clear()
            player.image=love.graphics.newImage("sprites/bang.png")
            --draw background
            love.graphics.draw(background.image, background.x, background.y)
            player:draw()
            love.graphics.present()
            local start = os.time()
            repeat until os.time() > start + 0.2
            player.image = love.graphics.newImage("sprites/canon.png")
            if lives == 0 then
                playerDead=true
            end
        end
        --check if bomb off screen
        if v.offScreen then
            table.remove(listOfBombs,i)
        end
    end

    if bonusInPlay and bonus.shot and clock > 1 then
        bonusInPlay=false
        bonus=nil
    end

    if clock > 1 then
        clock=0
    end

    
end

function love.draw()
    if startScreen then
        -- Display Start screen with instructions
        love.graphics.setNewFont(arkham_font, 24)
        love.graphics.printf("Alien Invaders!!!", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
        love.graphics.printf("Arrow keys - Left & Right", 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("Space bar - Shooot", 0, 280, love.graphics.getWidth(), "center")
        love.graphics.printf("Escape - Quit", 0, 310, love.graphics.getWidth(), "center")
        love.graphics.printf("Click Off/On Screen to Pause", 0, 340, love.graphics.getWidth(), "center")
        --get users name:
        love.graphics.setNewFont(14)
        love.graphics.print("Please Type your Name:> " .. playerName, (love.graphics.getWidth()/2)-90, 400)
        love.graphics.printf("Press ENTER to Start...", 0, 450, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
        return
    elseif gamePaused then
        love.graphics.printf("PAUSED", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
        return
    elseif playerDead then
        --save the high scores 
        highscore.save(playerName, score)
        love.graphics.setNewFont(arkham_font, 24)
        love.graphics.printf("GAME OVER!!", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
        love.graphics.printf("You Scored : " .. score .. "  Level : " .. level, 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("Press 's' to play again", 0, 300, love.graphics.getWidth(), "center")
        love.graphics.printf("or 'escape' to Quit", 0, 330, love.graphics.getWidth(), "center")
        --display highest scorer
        local h_scores = highscore.load()
        love.graphics.printf("HIGH SCORE", 0, 400, love.graphics.getWidth(), "center")
        love.graphics.printf(h_scores[1] .. "   " .. h_scores[2], 0, 430, love.graphics.getWidth(), "center")
        --love.graphics.printf(h_scores[1], 0, 430, love.graphics.getWidth(), "center")
        return
    end

    --draw background
    love.graphics.draw(background.image, background.x, background.y)

    love.graphics.print("Score: " .. score, 20, 20)

    if bigBonus > 0 then
        love.graphics.setNewFont(18)
        love.graphics.printf(bigBonusText[bigBonus], 0, 20, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
    end
    love.graphics.print("Lives: " .. lives, love.graphics.getWidth()-70, 20)
    --draw pplayer, bonus, alines, bullets & bombs!
    player:draw()
    if bonusInPlay then
        bonus:draw()
    end
    for n, e in ipairs (listOfEnemies) do
        e:draw()   
    end
    for i, v in ipairs (listOfBullets) do
        v:draw()
    end
    for i, v in ipairs (listOfBombs) do
        v:draw()
    end

    
end

function love.textinput(t)
    if startScreen then
        playerName = playerName .. t
    end
end

--check if player presses any keys
--this gets invoked on a keypress event
function love.keypressed(key)
    if key == "space" then
        player:keyPressed(key)
    elseif key == "escape" then
        love.event.quit("Thank you for Playing!")
    elseif key == "s" and not startScreen then 
        --restart game
        love.load()
    elseif key == "return" then 
        --start game
        startScreen = false
        --stop the intro music
        love.audio.stop()
        --turn off key repeat
        love.keyboard.setKeyRepeat(false)
    elseif key == "backspace" then
        local byteoffset = utf8.offset(playerName,-1)
        if byteoffset then
            playerName = string.sub(playerName, 1, byteoffset-1)
        end
    end
end

--check if player has moved to another application window
--if so, pause the game
function love.focus(f)
    gamePaused = not f
end


--function for when you clear all aliens on a level
function levelUp()
    level = level + 1

    --lets speed them up! on levels 5 & 10
    if level == 5 or level == 10 or level == 15 then
        enemySpeed = enemySpeed + (level * 5)
    end

    --remove the bonus alien in case it is still live
    if bonusInPlay then
        bonusInPlay=false
        bonus=nil
    end

    --remove all existng aliens
    listOfEnemies ={}
    listOfBullets={}
    listOfBombs={}

      --create new ones (number of aliens depending on level)
      --put them at random Y pixels
    for i = 1, level do
        table.insert (listOfEnemies, Enemy(40 + (25 * i)))
    end

    love.graphics.clear()
    love.graphics.setNewFont(arkham_font, 24)
    love.graphics.printf("LEVEL : " .. level, 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    love.graphics.present()
    local start = os.time()
    repeat until os.time() > start + 1.5
    love.graphics.setNewFont(12) 

    clock = 0
end

