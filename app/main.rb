DI_COLORS = {
  black: [0, 0, 0],
  white: [255, 255, 255],
  red: [255, 0, 0],
  lime: [0, 255, 0],
  blue: [0, 0, 255],
  yellow: [255, 255, 0],
  cyan: [0, 255, 255],
  magenta: [255, 0, 255],
  silver: [192, 192, 192],
  gray: [128, 128, 128],
  maroon: [128, 0, 0],
  olive: [128, 128, 0],
  green: [0, 128, 0],
  purple: [128, 0, 128],
  teal: [0, 128, 128],
  navy: [0, 0, 128]
}

DI_TEXT_ALIGN = {
  left: 0,
  center: 1,
  right: 2
}

SPRITES = {
  grass_tl_corner:  {sprite: 'sprites/KennyRPG/rpgTile000.png', solid: false},
  grass_top:        {sprite: 'sprites/KennyRPG/rpgTile001.png', solid: false},
  grass_tr_corner:  {sprite: 'sprites/KennyRPG/rpgTile002.png', solid: false},
  grass_left:       {sprite: 'sprites/KennyRPG/rpgTile018.png', solid: false},
  grass:            {sprite: 'sprites/KennyRPG/rpgTile019.png', solid: false},
  grass_right:      {sprite: 'sprites/KennyRPG/rpgTile020.png', solid: false},
  grass_bl_corner:  {sprite: 'sprites/KennyRPG/rpgTile036.png', solid: false},
  grass_bottom:     {sprite: 'sprites/KennyRPG/rpgTile037.png', solid: false},
  grass_br_corner:  {sprite: 'sprites/KennyRPG/rpgTile038.png', solid: false},
}

def tick args
  scene_main(args)
end

def scene_main args
  #Constants
  font0 = "font.tff"

  #Magic Numbers
  s_left = args.grid.left
  s_right = args.grid.right
  s_top = args.grid.top
  s_bottom = args.grid.bottom
  s_pad = 10

  map_handler(args, :mainMap)
  ui_basic(args)

  key_held = args.inputs.keyboard.key_held
  
  if key_held.escape
    $gtk.request_quit
  end

  args.state.mushroom_x ||= rand(15)
  args.state.mushroom_y ||= rand(8)
  args.outputs.sprites << mushroom = [args.state.map_cellsize * args.state.mushroom_x, args.state.map_cellsize * args.state.mushroom_y, 40, 40, 'sprites/flower.png']

  move_character(args)
  character = [args.state.character_x, args.state.character_y , args.state.map_cellsize, args.state.map_cellsize].solid
  
  if mushroom.intersect_rect? character
    args.state.mushroom_x = rand(15)
    args.state.mushroom_y = rand(8)
    args.state.mushrooms += 1
  end
end

def map_handler(args, map)
  # Screen Resolution is always 1280x720
  maps = args.state.maps = {
    mainMap: [ # Cellsize 80, 16 Wide [0-15], 9 Tall [0-8]
      SPRITES[:grass_tl_corner].merge({x: 0,  y: 8, endx: 0,   endy: 8}),
      SPRITES[:grass_top].merge(      {x: 1,  y: 8, endx:14,   endy: 8}),
      SPRITES[:grass_tr_corner].merge({x: 15, y: 8, endx: 15,  endy: 8}),
      SPRITES[:grass_left].merge(     {x: 0,  y: 0,  endx:0,    endy: 7}),
      SPRITES[:grass].merge(          {x: 1,  y: 1,  endx:14,   endy: 7}),
      SPRITES[:grass_right].merge(    {x: 15, y: 1,  endx:15,   endy: 7}),
      SPRITES[:grass_bl_corner].merge({x: 0,  y: 0,  endx: 0,   endy: 0}),
      SPRITES[:grass_bottom].merge(   {x: 1,  y: 0,  endx: 14,  endy: 0}),
      SPRITES[:grass_br_corner].merge({x: 15, y: 0,  endx: 15,  endy: 0})
     ]
  }

  # 1, 2, 4, 5, 8, 10, 16, 20, 40, 80
  cellsize = args.state.map_cellsize = 80

  x_cells = args.grid.right / cellsize
  y_cells = args.grid.top / cellsize
  
  maps[:mainMap].each_with_index { | cell, index |
    x_iter = cell[:x]
    y_iter = cell[:y]
    while x_iter < cell[:endx] + 1
      while y_iter < cell[:endy] + 1
        args.outputs.sprites << [x_iter * cellsize, y_iter * cellsize, cellsize, cellsize, cell[:sprite]]
        y_iter += 1
      end
      x_iter += 1
      y_iter = cell[:y]
    end
  }
end

def move_character args
  args.state.character_x ||= 100
  args.state.character_y ||= 100
  speed = args.state.character_speed = 5
  char_anim = args.state.sprite_char_anim = :idle

  vect = args.inputs.directional_vector
  if vect
    if vect[0] != 0 && vect[1] != 0
      args.state.character_x += ((vect.x).round * 0.7071 * args.state.character_speed).round # 0.7071 is a magic number that will have diagonal speed = 1 to 4 decimal places
      args.state.character_y += ((vect.y).round * 0.7071 * args.state.character_speed).round
    else
      args.state.character_x += vect.x * args.state.character_speed
      args.state.character_y += vect.y * args.state.character_speed
    end
    char_anim = args.state.char_anim = :run
    anim_speed = 5
  else
    char_anim = args.state.char_anim = :idle
    anim_speed = 20
  end

  char_sprite_handler(args, action: char_anim, x: args.state.character_x, y:args.state.character_y, anim_speed: anim_speed, vector: vect)
end

def char_sprite_handler(args, action:, x:, y:, vector:, anim_speed:)
  args.state.sprite_char_x_index ||= 1
  args.state.sprite_char_y_index ||= 1

  case action
    when :idle
      args.state.sprite_char_anim = :idle
      anim_start = [1, 1]
      anim_end = [3, 1]
    when :run
      args.state.sprite_char_anim = :run
      anim_start = [1, 2]
      anim_end = [4, 2]
    else
      args.state.sprite_char_anim = :idle
      anim_start = [1, 1]
      anim_end = [3, 1]
  end
  
  if args.state.tick_count % anim_speed == 0
    args.state.sprite_char_x_index += 1

    if args.state.sprite_char_x_index > anim_end[0]
      args.state.sprite_char_x_index = anim_start[0]
      args.state.sprite_char_y_index += 1

      if args.state.sprite_char_y_index > anim_end[1]
        sprite_x = args.state.sprite_char_x_index = anim_start[0]
        sprite_y = args.state.sprite_char_y_index = anim_start[1]
      end
    end
  end
  anim_x = args.state.sprite_char_x_index
  anim_y = args.state.sprite_char_y_index

  if vector
    if vector[0] > 0
      flip = true
    else
      flip = false
    end
  end

  args.outputs.sprites << char_sprite(args, anim_x: anim_x, anim_y: anim_y, flip: flip)
  
end

def char_sprite(args, anim_x:, anim_y:, flip: flip)
  {
  x: args.state.character_x,
  y: args.state.character_y,
  w: args.state.map_cellsize,
  h: args.state.map_cellsize,
  path: "/sprites/Sprite Pieces/row-#{anim_y}-col-#{anim_x}.png",
  flip_horizontally: flip,
  }
end

def ui_basic args

  #Constants
  font0 = "font.tff"

  #Magic Numbers
  s_left = args.grid.left
  s_right = args.grid.right
  s_top = args.grid.top
  s_pad = 10

  #Money Count
  mushrooms = args.state.mushrooms ||=0
  text = mushrooms.to_s
  text_size = 3
  text_color = DI_COLORS[:black]
  args.outputs.labels << {x: s_right / 2, y: s_top - s_pad, text: text, size_enum: text_size, alignment_enum: DI_TEXT_ALIGN[:center], r: text_color[0], g: text_color[1], b: text_color[2], a: 255, font: font0}

end