class BlurEffect
    FADE_DURATION = 30  # Duration for fade-in/out in frames
    OPACITY_MAX = 190   # Maximum opacity value for the blur sprite
    DARKNESS_OPACITY = 128  # Opacity for darkening the screen
  
    def initialize
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @sprites = []
      @darkness_sprite = nil
    end
  
    def start_blur
      @sprites.each { |sprite| sprite.dispose }
      @sprites.clear
  
      @darkness_sprite.dispose if @darkness_sprite
      @darkness_sprite = nil
  
      bitmap = Graphics.snap_to_bitmap
      blurred_bitmap = Bitmap.new(Graphics.width / 4, Graphics.height / 4)
      blurred_bitmap.stretch_blt(blurred_bitmap.rect, bitmap, bitmap.rect)
      blurred_bitmap.blur
  
      sprite = Sprite.new(@viewport)
      sprite.bitmap = blurred_bitmap
      sprite.zoom_x = 4
      sprite.zoom_y = 4
      sprite.opacity = 0  # Start with opacity 0
      @sprites << sprite
  
      darkness_sprite = Sprite.new(@viewport)
      darkness_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      darkness_sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, DARKNESS_OPACITY))
      darkness_sprite.opacity = 0
      @darkness_sprite = darkness_sprite
  
      fade_in(sprite)
      fade_in(darkness_sprite)
    end
  
    def fade_in(sprite)
      opacity_increment = OPACITY_MAX / FADE_DURATION.to_f
      for i in 0...FADE_DURATION
        sprite.opacity += opacity_increment
        Graphics.update
      end
    end
  
    def fade_out(sprite)
      opacity_decrement = OPACITY_MAX / FADE_DURATION.to_f
      for i in 0...FADE_DURATION
        sprite.opacity -= opacity_decrement
        Graphics.update
      end
    end
  
    def dispose
      fade_out(@darkness_sprite) if @darkness_sprite # Fade out the darkness effect sprite first
      fade_out(@sprites.last) # Fade out the blur effect sprite last
  
      @sprites.each { |sprite| sprite.dispose }
      @sprites.clear
  
      @darkness_sprite.dispose if @darkness_sprite
      @darkness_sprite = nil
  
      @viewport.dispose
    end
  end