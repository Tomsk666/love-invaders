--High score file handling functions
-- adapted from SICK: Simple Indicative of Competitive sKill

local h = {}

function h.set(filename)
   h.filename = filename
   local file = love.filesystem.newFile(h.filename)
   --if the file is not there, create it with the default values
   if not love.filesystem.getInfo(h.filename) or not file:open("r") then 
      file:open("w") 
      file:write("AAA" .. "\t" .. 10 .. "\n")
      file:close()
   end
end

function h.load()
   local file = love.filesystem.newFile(h.filename)
   if not love.filesystem.getInfo(h.filename) or not file:open("r") then return end
   local scores = {}
   line =file:read()
   local i = line:find('\t', 1, true)
   scores = {line:sub(1, i-1), tonumber(line:sub(i+1))}
   file:close()
   return scores
end


function h.save(name, curr_score)
   local saved_scores = h.load()
   if saved_scores[2] > curr_score then
      return
   end
   --write the new high score to file
   local file = love.filesystem.newFile(h.filename)
   if not file:open("w") then return end
   --write the scores
   file:write(name .. "\t" .. curr_score .. "\n")
   return file:close()
end


local highscore = h

return h