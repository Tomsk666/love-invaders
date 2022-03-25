-- My utility functions for global use
local funcs = {}

function funcs.collided (obj1, obj2)
    local self_left=obj1.x
    local self_right=obj1.x + obj1.width
    local self_top=obj1.y
    local self_bottom=obj1.y + obj1.height

    local obj_left=obj2.x
    local obj_right=obj2.x + obj2.width
    local obj_top=obj2.y
    local obj_bottom=obj2.y + obj2.height

    if self_right > obj_left
    and self_left < obj_right
    and self_bottom >obj_top
    and self_top < obj_bottom then
        return true
    end

    return false
end


return funcs