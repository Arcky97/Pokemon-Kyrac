class SummaryScreen
  FADE = 30 # Duration of the fade
  DARKNESS = 200  # Opacity for darkening the screen

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprite = nil
  end

  def startSummary
    @sprite.dispose if @Sprite
    @sprite = nil
    sprite = Sprite.new(@viewport)
    sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    sprite.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, DARKNESS))
    sprite.opacity = 0
    @sprite = sprite
    fadeIn(sprite)
  end

  def fadeIn(sprite)
    opacity = DARKNESS / FADE.to_f
    for i in 0...FADE
      sprite.opacity += opacity
      Graphics.update
    end
  end

  def fade_out(sprite)
    opacity = DARKNESS / FADE.to_f
    for i in 0...FADE
      sprite.opacity -= opacity
      Graphics.update
    end
  end

  def dispose
    fade_out(@sprite) if @sprite # Fade out the darkness effect sprite
    @sprite.dispose if @sprite
    @sprite = nil
    @viewport.dispose
  end
end