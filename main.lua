-- https://youtu.be/I549C6SmUnk?t=17375
local love = require "love"
local enemy = require "Enemy"
local button = require "Button"

math.randomseed(os.time())

local game = {
  state = {
    menu = true,
    paused = false,
    running = false,
    ended = false
  },
  difficulty = 1,
  points = 0,
  levels = {15, 30, 60, 120}
}

local fonts = {
  medium = {
    font = love.graphics.newFont(16),
    size = 16
  },
  large = {
    font = love.graphics.newFont(24),
    size = 24
  },
  massive = {
    font = love.graphics.newFont(60),
    size = 60
  },
}

local player = {
  radius = 20,
  x = 30,
  y = 30
}

local buttons = {
  menu_state = {}
}

local enemies = {}

local function changeGameState(state)
  game.state["menu"] = state == "menu"
  game.state["paused"] = state == "paused"
  game.state["running"] = state == "running"
  game.state["ended"] = state == "ended"
end

local function startNewGame()
  changeGameState("running")

  game.points = 0

  enemies = { enemy(1) }
end

function love.mousepressed(x, y, button, istouch, presses)
  if not game.state["running"] then
    if button == 1 then
      if game.state ["menu"] then
        for index in pairs(buttons.menu_state) do
          buttons.menu_state[index]:checkPressed(x, y, player.radius)
        end
      end
    end
  end
end

function love.load()
  love.window.setTitle("Save the ball")
  love.mouse.setVisible(false)

  buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
  buttons.menu_state.settings = button("Settings", nil, nil, 120, 40)
  buttons.menu_state.exit_game = button("Exit Game", love.event.quit, nil, 120, 40)

  table.insert(enemies, 1, enemy())
end


function love.update(dt)
  player.x, player.y = love.mouse.getPosition()

  if game.state["running"] then
    for i=1, #enemies do
      if not enemies[i]:checkTouched(player.x, player.y, player.radius) then
        enemies[i]:move(player.x, player.y)
        
        for i = 1, #game.levels do
          if math.floor(game.points) == game.levels[i] then
            table.insert(enemies, 1, enemy(game.difficulty * (i + 1)))

            game.points = game.points + 1
          end
        end
      else
        changeGameState("menu")
      end

    end
    game.points = game.points + dt --one point per second
  end

end

function love.draw()
  love.graphics.setFont(fonts.medium.font)
  love.graphics.printf(
    "FPS: " .. love.timer.getFPS(),
    fonts.medium.font,
    10,
    love.graphics.getHeight() - 30,
    love.graphics.getWidth()
  )
  if game.state["running"] then
    love.graphics.printf(math.floor(game.points), fonts.large.font, 0, 10, love.graphics.getWidth(), "center")

    for i=1, #enemies do
      enemies[i]:draw()
    end

    love.graphics.circle("fill", player.x, player.y, player.radius)
  elseif game.state["menu"] then
    buttons.menu_state.play_game:draw(10, 20, 17, 10)
    buttons.menu_state.settings:draw(10, 70, 17, 10)
    buttons.menu_state.exit_game:draw(10, 120, 17, 10)
  end

  if not game.state["running"] then
    love.graphics.circle("fill", player.x, player.y, player.radius / 2)
  end
end