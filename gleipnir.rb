require 'chingu'
include Gosu

class Gleipnir < Chingu::Window
  def setup
    self.caption = "Gleipnir!"
    push_game_state StartingZone
  end
end

## STATES

=begin
class Intro < Chingu::GameState
  def setup
    Chingu::Text.create(:text => "G L E I P N I R", :x => 375, :y => 50)
    Chingu::Text.create(:text => "Programming by Nate Wolfe", :x => 350, :y => 150)
    Chingu::Text.create(:text => "Artwork by Lew Lewis", :x => 365, :y => 170)
    Chingu::Text.create(:text => "PRESS S TO START", :x => 370, :y => 400)
    self.input = {:s => StartingZone, :escape => :exit}
  end
end
=end

class StartingZone < Chingu::GameState
  trait :viewport

  def setup
    self.input = {:escape => :exit, :e => Chingu::GameStates::Edit}
    self.viewport.lag = 0
    self.viewport.game_area = [0, 0, 864, 672]
    fill_with_grass
    load_game_objects
    @player = Player.create(:x => 200, :y => 200)
  end

  def fill_with_grass
    tiles_per_row = (self.viewport.game_area.width / 32) + 1
    tiles_per_col = (self.viewport.game_area.height / 32) + 1

    tiles_per_col.times do |col|
      y = col * 32
      tiles_per_row.times do |row|
        x = row * 32
        Grass.create(:x => x, :y => y)
      end
    end
  end

  def update
    super
    self.viewport.center_around(@player)
  end
end

## PLAYER

class Player < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    self.input = {
      [:holding_up, :holding_k] => :move_up,
      [:released_up, :released_k] => :halt_up,

      [:holding_down, :holding_j] => :move_down,
      [:released_down, :released_j] => :halt_down,

      [:holding_left, :holding_h] => :move_left,
      [:released_left, :released_h] => :halt_left,
        
      [:holding_right, :holding_l] => :move_right,
      [:released_right, :released_l] => :halt_right
    }

    @animations = Chingu::Animation.new(:file => "player/player_sheet2_32x32.png")
    @animations.frame_names = {
      :down => 0..2, 
      :up => 3..5, 
      :right => 6..8, 
      :left => 9..11
    }
    @image = @animations[:down].next
    update
  end

  def update
    @last_x = @x
    @last_y = @y
  end

  def kollides?
    return self.first_collision(DarkBrick) || 
    self.first_collision(BushyTree) || 
    self.first_collision(BushyTreeApples) || 
    self.first_collision(WillowTree)
    self.first_collision(RockWall) || 
    self.first_collision(CaveWall) || 
    self.first_collision(CaveWall2) || 
    self.first_collision(CaveWallGold) || 
    self.first_collision(CaveWallShade)
  end

  def move(x, y)
    if x > 0 || x < 0
      @x += x
      @x = @last_x if kollides?
    end

    if y > 0 || y < 0
      @y += y
      @y = @last_y if kollides?
    end
  end

  def move_left
    @image = @animations[:left].next
    move(-2, 0)
  end

  def halt_left
    @image = @animations[:left].first
  end

  def move_right
    @image = @animations[:right].next
    move(2, 0)
  end

  def halt_right
    @image = @animations[:right].first
  end

  def move_up
    @image = @animations[:up].next
    move(0, -2)
  end

  def halt_up
    @image = @animations[:up].first
  end

  def move_down
    @image = @animations[:down].next
    move(0, 2)
  end

  def halt_down
    @image = @animations[:down].first
  end
end

## FLOOR TILES

class Dirt < Chingu::GameObject
  def setup
    @image = Image["floor/dirt.png"]
  end
end

class Grass < Chingu::GameObject
  def setup
    @image = Image["floor/grass.png"]
  end
end

class GrassRocks < Chingu::GameObject
  def setup
    @image = Image["floor/grass_rocks.png"]
  end
end

class Gravel < Chingu::GameObject
  def setup
    @image = Image["floor/gravel.png"]
  end
end

class MossGround < Chingu::GameObject
  def setup
    @image = Image["floor/moss_ground.png"]
  end
end

class MossStone < Chingu::GameObject
  def setup
    @image = Image["floor/moss_stone.png"]
  end
end

class Mud < Chingu::GameObject
  def setup
    @image = Image["floor/mud.png"]
  end
end

class MudFloor < Chingu::GameObject
  def setup
    @image = Image["floor/mud_floor.png"]
  end
end

class MudFloorGold < Chingu::GameObject
  def setup
    @image = Image["floor/mud_floor_gold.png"]
  end
end

class RockPath < Chingu::GameObject
  def setup
    @image = Image["floor/rock_path.png"]
  end
end

## WALL TILES
  
class DarkBrick < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["wall/dark_brick.png"]
  end
end

class BushyTree < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["terrain/bushy_tree.png"]
  end
end

class BushyTreeApples < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["terrain/bushy_tree_apples.png"]
  end
end

class WillowTree < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["terrain/willow.png"]
  end
end

class RockWall < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["wall/rock_wall.png"]
  end
end

class CaveWall < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["wall/cave_wall.png"]
  end
end

class CaveWall2 < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["wall/cave_wall_2.png"]
  end
end

class CaveWallGold < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["wall/cave_wall_gold.png"]
  end
end

class CaveWallShade < Chingu::GameObject
  traits :bounding_box, :collision_detection

  def setup
    @image = Image["wall/cave_wall_shade.png"]
  end
end

Gleipnir.new.show
