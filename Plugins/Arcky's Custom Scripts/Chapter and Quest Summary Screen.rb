class SummaryScreen
    DURATION = 25  # Duration for fade-in/out in frames
    OPACITY = 170  # Opacity for darkening the screen
  
    def initialize
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @sprites = []
      @sprites2 = []
    end
  
    def main  
      bitmap = Graphics.snap_to_bitmap
      blurr = Bitmap.new(Graphics.width / 4, Graphics.height / 4)
      blurr.stretch_blt(blurr.rect, bitmap, bitmap.rect)
      blurr.blur
  
      sprite = Sprite.new(@viewport)
      sprite.bitmap = blurr
      sprite.zoom_x = 4
      sprite.zoom_y = 4
      sprite.opacity = 0 
      @sprites = sprite
  
      sprite2 = Sprite.new(@viewport)
      sprite2.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      sprite2.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, OPACITY))
      sprite2.opacity = 0
      @sprites2 = sprite2
  
      fadeIn()
    end
  
    def fadeIn
      opacityLevel = OPACITY / DURATION.to_f
      for i in 0...DURATION
        @sprites.opacity += opacityLevel
        @sprites2.opacity += opacityLevel
        Graphics.update
      end
    end

    def fadeOut
      opacityLevel = OPACITY / DURATION.to_f
      for i in 0...DURATION
        @sprites.opacity -= opacityLevel
        @sprites2.opacity -= opacityLevel
        Graphics.update
      end
    end
  
    def dispose
      fadeOut()
      @sprites.dispose
      @sprites2.dispose
      @viewport.dispose
    end
  end