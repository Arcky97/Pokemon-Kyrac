class SummaryScreen
  def initialize(message = nil, messageDuration = 120, duration = 25, opacity = 170)
    @message, @fontSize = message.transpose  if message
    @messageDuration = messageDuration
    @duration = duration
    @opacity = opacity 
    @opacityLevel = @opacity / @duration.to_f
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = {} 
    main
    showMessage if @message
  end 

  def main  
    bitmap = Graphics.snap_to_bitmap
    blurr = Bitmap.new(Graphics.width / 4, Graphics.height / 4)
    blurr.stretch_blt(blurr.rect, bitmap, bitmap.rect)
    blurr.blur

    @sprites["blurr"] = Sprite.new(@viewport)
    @sprites["blurr"].bitmap = blurr 
    @sprites["blurr"].zoom_x = 4
    @sprites["blurr"].zoom_y = 4
    @sprites["blurr"].opacity = 0

    @sprites["backshade"] = Sprite.new(@viewport)
    @sprites["backshade"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["backshade"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, @opacity))
    @sprites["backshade"].opacity = 0

    fadeIn
  end

  def showMessage
    # Calculate the total height needed for all texts
    textSpace = 5
    totalHeight = @fontSize.sum + (textSpace * (@message.length))
    # Set the minimum height of the viewport to fit all the texts
    viewportHeight = [totalHeight, Graphics.height].min
    # Draw the viewport on the screen and center it
    @textviewport = Viewport.new(0, ((Graphics.height / 2) - (viewportHeight / 2)), Graphics.width, viewportHeight)
    # Center the texts vertically within the viewport
    startY = 0
    # Now we need to center the texts horizontally and draw them in the viewport
    @message.each_with_index do |text, index|
      @sprites["displaytext#{index}"] = BitmapSprite.new(@textviewport.rect.width, @textviewport.rect.height, @textviewport)
      @sprites["displaytext#{index}"].x = 0
      @sprites["displaytext#{index}"].y = startY
      startY += @fontSize[index] + textSpace
      @sprites["displaytext#{index}"].bitmap.clear
      @sprites["displaytext#{index}"].opacity = 0
      pbSetSystemFont(@sprites["displaytext#{index}"].bitmap)
      @sprites["displaytext#{index}"].bitmap.font.size = @fontSize[index]
      pbDrawTextPositions(@sprites["displaytext#{index}"].bitmap, [[_INTL("#{text}"), Graphics.width / 2, 0, 2, MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR]])
      opacityLevel = 255 / @duration.to_f
      for i in 0..@duration
        @sprites["displaytext#{index}"].opacity += opacityLevel
        Graphics.update
      end
    end
  
    pbWait(@messageDuration + 60)
    (@message.length - 1).downto(0) do |i|
      for j in 0..@duration
        @sprites["displaytext#{i}"].opacity -= @duration.to_f
        Graphics.update
      end
      @sprites["displaytext#{i}"].dispose
    end
  
    @textviewport.dispose
    dispose
  end

  def fadeIn
    for i in 0...@duration
      @sprites["blurr"].opacity += @opacityLevel
      @sprites["backshade"].opacity += @opacityLevel
      Graphics.update
    end
  end

  def fadeOut
    for i in 0...@duration
      @sprites["blurr"].opacity -= @opacityLevel
      @sprites["backshade"].opacity -= @opacityLevel
      Graphics.update
    end
  end

  def dispose
    fadeOut
    @sprites["blurr"].dispose
    @sprites["backshade"].dispose
    @viewport.dispose
  end
end