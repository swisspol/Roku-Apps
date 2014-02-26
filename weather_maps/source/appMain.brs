' http://www.ssd.noaa.gov/goes/west/wfo/mtr.html
' http://radar.weather.gov/Conus/pacsouthwest.php
' http://radar.weather.gov/Conus/RadarImg/latest.gif

Function Timestamp() as String
  now = CreateObject("roDateTime")
  return now.GetYear().ToStr() + "-" + now.GetMonth().ToStr() + "-" + now.GetDayOfMonth().ToStr() + " " + now.GetHours().ToStr() + ":" + now.GetMinutes().ToStr() + ":" + now.GetSeconds().ToStr()
End Function

Sub Main()
  background_color = &h333333FF
  
  port = CreateObject("roMessagePort")
  screen = CreateObject("roScreen", true)  ' 1280x720 pixels
  screen.SetMessagePort(port)
  screen.Clear(background_color)
  screen.SwapBuffers()
  
  image_path_1 = "tmp:/image_1.gif"
  transfer1 = CreateObject("roUrlTransfer")
  transfer1.SetMessagePort(port)
  transfer1.SetUrl("http://radar.weather.gov/Conus/RadarImg/pacsouthwest.gif")  ' 600x571 pixels
  transfer1.AsyncGetToFile(image_path_1)
  identity_1 = transfer1.GetIdentity()
  bitmap_1 = Invalid
  
  image_path_2 = "tmp:/image_2.gif"
  transfer2 = CreateObject("roUrlTransfer")
  transfer2.SetMessagePort(port)
  transfer2.SetUrl("http://sat.wrh.noaa.gov/satellite/1km/Monterey/VIS1MRY.GIF")  ' 680x480 pixels
  transfer2.AsyncGetToFile(image_path_2)
  identity_2 = transfer2.GetIdentity()
  bitmap_2 = Invalid
  
  While True
    msg = wait(0, screen.GetMessagePort())
    if type(msg) = "roUniversalControlEvent"
      button = msg.GetInt()
      if button = 7  'Replay
        exit while
      end if
    else if type(msg) = "roUrlEvent"
      if msg.GetInt() = 1
        if msg.GetResponseCode() = 200
          if msg.GetSourceIdentity() = identity_1
            bitmap_1 = CreateObject("roBitmap", image_path_1)
            print "Downloaded image 1 (" + Timestamp() + "):" + bitmap_1.GetWidth().ToStr() + "x" + bitmap_1.GetHeight().ToStr()
          else if msg.GetSourceIdentity() = identity_2
            bitmap_2 = CreateObject("roBitmap", image_path_2)
            print "Downloaded image 2 (" + Timestamp() + "):" + bitmap_2.GetWidth().ToStr() + "x" + bitmap_2.GetHeight().ToStr()
          end if
          if bitmap_1 <> Invalid AND bitmap_2 <> Invalid
            screen.Clear(&h333333FF)
            screen.DrawObject(25, 50, bitmap_1)
            screen.DrawObject(600, 120, bitmap_2)
            screen.DrawRect(0, 0, 1280, 120, background_color)
            screen.DrawRect(0, 600, 1280, 120, background_color)
            screen.SwapBuffers()
            print "Updated screen"
          end if
        else
          print msg.GetFailureReason()
        end if
      end if
    end if
  end while
End Sub
