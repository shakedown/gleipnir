class ZoneBuilder

  def initialize(zone_height, zone_width, tile_size)
    @zone_height = zone_height
    @zone_width = zone_width
    @tile_size = tile_size
  end

  def place_tile(tile_class, x, y, replace)
    tile = tile_class.create(:x => x, :y => y)
    destroy_tiles_in_same_location(tile) if replace
  end

  def destroy_tiles_in_same_location(tile)
    [BushyTree, WillowTree, Grass].each do |wall_class|
      wall_class.all.each do |wall|
        wall.destroy if tile != wall && tile.x == wall.x && tile.y == wall.y
      end
    end
  end

  def fill_block(starting_x, starting_y, width, height)
    width = snap_to_size(width, @tile_size)
    height = snap_to_size(height, @tile_size)
    tpr = width / @tile_size
    tpc = height / @tile_size

    tpr.times do |row|
      x = starting_x + (row * @tile_size)
      tpc.times do |col|
        y = starting_y + (col * @tile_size)
        yield(x, y)
      end
    end
  end

  def fill(starting_x, starting_y, width, height, tile_class, replace = true)
    fill_block(starting_x, starting_y, width, height) do |x, y|
      place_tile(tile_class, x, y, replace)
    end
  end

  def fill_with_grass
    fill(0, 0, @zone_width, @zone_height, Grass, false)
  end

  def fill_with_trees
    fill_block(0, 0, @zone_width, @zone_height) do |x, y|
      tree = [BushyTree, WillowTree].sample
      place_tile(tree, x, y, false)
    end
  end

  def snap_to_tile(length)
    snap_to_size(length, @tile_size)
  end

  def snap_to_size(length, size)
    ((length.to_f / size).ceil) * size
  end

  def entrance_coordinates
    {
      :x => @zone_width / 4,
      :y => 0,
      :width => @zone_width / 5
    }
  end

  def place_player_at_entrance(player)
    player.x = entrance_coordinates[:x] + (entrance_coordinates[:width] / 2)
    player.y = entrance_coordinates[:y] + @tile_size
  end

  # roughness = how much the cave varies in width, 1 to 100
  # windyness = how much the cave varies in positioning, 1 to 100
  def build_zone(roughness, windyness)
    #length = (@zone_height / @tile_size) - 1 # how long the cave should be in tiles (fixed or not fixed)

    # start with layers of grass and trees
    fill_with_grass
    fill_with_trees

    # entrance / init
    starting_x = snap_to_tile entrance_coordinates[:x]
    starting_y = entrance_coordinates[:y]
    starting_width = entrance_coordinates[:width]
    fill(starting_x, starting_y, starting_width, @tile_size, Grass)
    fill(starting_x, @tile_size, starting_width, @tile_size, Grass)

    x = starting_x
    y = starting_y
    width = starting_width

    while (y - starting_y < @zone_height)
      y += @tile_size

      if rand(1..100) <= roughness
        width += @tile_size * [-2, -1, 1, 2].sample
        width = 3 * @tile_size if width < (3 * @tile_size)
        width = @zone_width if width > @zone_width
      end

      if rand(1..100) <= windyness
        x += @tile_size * [-2, -1, 1, 2].sample
        x = 0 if x < 0
        x = @zone_width - (3 * @tile_size) if x > (@zone_width - (3 * @tile_size))
      end

      fill(x, y, width, @tile_size, Grass)
    end
  end

  def place_enemies
    8.times {
      enemy = Enemy.create
      randomly_position(enemy) while enemy.collision_detected?
    }
  end

  def randomly_position(enemy)
    enemy.x = rand($window.width)
    enemy.y = rand($window.height)
  end
end
