local main_menu_state = state:new()
main_menu_state.label = 'main_menu_state'
local state = main_menu_state

--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      INPUT
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function main_menu_state.keypressed(key)
  state.flock:keypressed(key)
end
function main_menu_state.keyreleased(key)
  state.flock:keyreleased(key)
end
function main_menu_state.mousepressed(x, y, button)
  state.flock:mousepressed(x, y, button)
  
  if not surface_theshold then surface_threshold = 0.5 end
  if not point_radius then point_radius = 200 end
  local inc = 30
  local inc2 = 0.05
  if button == "wu" then
    if lk.isDown("lctrl") then
      surface_threshold = surface_threshold + inc2
    else
      point_radius = point_radius + inc
    end
  end
  if button == "wd" then
    if lk.isDown("lctrl") then
      surface_threshold = surface_threshold - inc2
    else
      point_radius = point_radius - inc
    end
  end
  
  if button == 'l' and lk.isDown("lshift") then
    local x, y = state.level:get_mouse():get_position():get_vals()
    local cx, cy = state.level:get_camera():get_viewport()
    local x, y = x + cx, y + cy
    local level_map = state.level:get_level_map()
    
    level_map:set_polygonizer_surface_threshold(surface_threshold)
    level_map:add_point_to_polygonizer(x, y, point_radius)
    level_map:update_polygonizer()
  end
  
end
function main_menu_state.mousereleased(x, y, button)
  state.flock:mousereleased(x, y, button)
end


--##########################################################################--
--[[----------------------------------------------------------------------]]--
--      LOAD
--[[----------------------------------------------------------------------]]--
--##########################################################################--
function main_menu_state.load(level)
  state.level = level
  
  local tpad = 2
  local x, y = state.level.level_map.bbox.x + tpad * TILE_WIDTH, 
               state.level.level_map.bbox.y + tpad * TILE_HEIGHT
  local width, height = state.level.level_map.bbox.width - 2 * tpad * TILE_WIDTH, 
                        state.level.level_map.bbox.height - 2 * tpad * TILE_HEIGHT
  local depth = 1500
  state.flock = flock:new(state.level, x, y, width, height, depth)
  
  state.flock:add_boid(500, 500, 200)
end


--#########################################################################--
--[[----------------------------------------------------------------------]]--
--      UPDATE
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local t = 0
function main_menu_state.update(dt)
  -- camera movement test
  local cam = state.level:get_camera()
  local cpos = cam:get_center()
  local target = vector2:new(cpos.x, cpos.y)
  local tx, ty = 0, 0
  local speed = 1000
  if lk.isDown("w") then
    ty = ty - speed * dt
  end
  if lk.isDown("a") then
    tx = tx - speed * dt
  end
  if lk.isDown("s") then
    ty = ty + speed * dt
  end
  if lk.isDown("d") then
    tx = tx + speed * dt
  end
  target.x, target.y = target.x + tx, target.y + ty
  cam:set_target(target, true)

  state.flock:update(dt)
  state.level:update(dt)

end
  

--########################################d##################################--
--[[----------------------------------------------------------------------]]--
--     DRAW
--[[----------------------------------------------------------------------]]--
--##########################################################################--
local grad = require("gradients/named/orangeyellow")
function main_menu_state.draw()
  state.level:draw()
  
  state.level.camera:set()
  state.flock:draw()
  
  
  local x, y = state.level:get_mouse():get_position():get_vals()
  local cx, cy = state.level:get_camera():get_viewport()
  local x, y = x + cx + 0.001, y + cy + 0.001
  local nx, ny, i = state.level:get_level_map():get_field_vector_at_position({x=x, y=y})
  local len = 100
  
  if i > 0 then
    local len = 100
    local xf, yf = x + i * len * nx, y + i * len * ny
    lg.setColor(0, 255, 0, 255)
    lg.circle("line", x, y, len)
    lg.line(x, y, xf, yf)
  end

  if point_radius and surface_threshold then
    lg.setColor(0, 0, 0, 255)
    lg.circle("line", x, y, point_radius)
    lg.circle("line", x, y, point_radius * surface_threshold)
  end
  
  state.level.camera:unset()
end

return main_menu_state












