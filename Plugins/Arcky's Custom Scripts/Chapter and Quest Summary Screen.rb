class SummaryScreen
  BLUE = Color.new(51, 141, 249) # Blue
  RED = Color.new(237, 77, 64) # Red
  GREEN = Color.new(128, 192, 109) # Green
  CYAN = Color.new(109, 224, 224) # Cyan
  MAGENTA = Color.new(217, 96, 198) # Magenta
  YELLOW = Color.new(237, 217, 77) # Yellow
  GREY = Color.new(179, 179, 185) # Grey
  WHITE = Color.new(243, 243, 249) # White
  PURPLE = Color.new(166, 102, 237) # Purple
  ORANGE = Color.new(249, 173, 70) # Orange
  DEFAULT = [MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR] # Default White

  def initialize(message = nil, messageDuration = 120, duration = 25, opacity = 170)
    if message
      if message[0].is_a?(Array) && message[0].size == 3
        @message, @fontSize, @fontColor = message.transpose
      else
        @message, @fontSize = message.transpose
        @fontColor = []
      end
    end
    @messageDuration = messageDuration
    @duration = duration
    @opacity = opacity 
    @opacityLevel = @opacity / @duration.to_f
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sprites = {} 
    main
    showMessage if @message
  end 

  def getColor(color)
    color = color.downcase if color
    return BLUE if color == "blue"
    return RED if color == "red"
    return GREEN if color == "green"
    return CYAN if color == "cyan"
    return MAGENTA if color == "magenta"
    return YELLOW if color == "yellow"
    return GREY if color == "grey" || "gray"
    return WHITE if color == "white"
    return PURPLE if color == "purple"
    return ORANGE if color == "orange"
    return DEFAULT
  end

  def main  
    bitmap = Graphics.snap_to_bitmap
    blur = Bitmap.new(Graphics.width / 4, Graphics.height / 4)
    blur.stretch_blt(blur.rect, bitmap, bitmap.rect)
    blur.blur

    @sprites["blur"] = Sprite.new(@viewport)
    @sprites["blur"].bitmap = blur
    @sprites["blur"].zoom_x = 4
    @sprites["blur"].zoom_y = 4
    @sprites["blur"].opacity = 0

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
      fontColor = @fontColor[index] ? getColor(@fontColor[index]) : DEFAULT[0]
      @sprites["displaytext#{index}"] = BitmapSprite.new(@textviewport.rect.width, @textviewport.rect.height, @textviewport)
      @sprites["displaytext#{index}"].x = 0
      @sprites["displaytext#{index}"].y = startY
      startY += @fontSize[index] + textSpace
      @sprites["displaytext#{index}"].bitmap.clear
      @sprites["displaytext#{index}"].opacity = 0
      pbSetSystemFont(@sprites["displaytext#{index}"].bitmap)
      @sprites["displaytext#{index}"].bitmap.font.size = @fontSize[index]
      pbDrawTextPositions(@sprites["displaytext#{index}"].bitmap, [[_INTL("#{text}"), Graphics.width / 2, 0, 2, fontColor, DEFAULT[1]]])
      opacityLevel = 255 / @duration.to_f
      for i in 0..@duration
        @sprites["displaytext#{index}"].opacity += opacityLevel
        Graphics.update
      end
    end
    pbWait(@messageDuration + 60)
  for i in 0..@duration 
    (@message.length - 1).downto(0) do |j|
      @sprites["displaytext#{j}"].opacity -= @duration.to_f
      Graphics.update
      @sprites["displaytext#{j}"].dispose if !@sprites["displaytext#{j}"]
    end
  end
    @textviewport.dispose
    dispose
  end

  def fadeIn
    for i in 0...@duration
      @sprites["blur"].opacity += @opacityLevel
      @sprites["backshade"].opacity += @opacityLevel
      Graphics.update
    end
  end

  def fadeOut
    for i in 0...@duration
      @sprites["blur"].opacity -= @opacityLevel
      @sprites["backshade"].opacity -= @opacityLevel
      Graphics.update
    end
  end

  def dispose
    fadeOut
    @sprites["blur"].dispose
    @sprites["backshade"].dispose
    @viewport.dispose
  end
end


