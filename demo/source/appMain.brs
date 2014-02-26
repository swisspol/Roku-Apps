' ********************************************************************
' **  Test Roku app
' ********************************************************************

' http://sdkdocs.roku.com/display/sdkdoc/Manifest+File
' splash_screen_hd
' splash_screen_sd
' splash_min_time

Sub ShowMessageDialog()
  port = CreateObject("roMessagePort")
  dialog = CreateObject("roMessageDialog")
  dialog.SetMessagePort(port) 
  dialog.SetTitle("[Message dialog title]")
  dialog.SetText("[Message dialog text............]")
  dialog.AddButton(1, "[button text]")
  dialog.EnableBackButton(true)
  dialog.Show()
  
  While True
    msg = wait(0, dialog.GetMessagePort())
    if type(msg) = "roMessageDialogEvent"
      if msg.isButtonPressed()
        if msg.GetIndex() = 1
          exit while
        end if
      else if msg.isScreenClosed()
        exit while
      end if
    end if
  end while
End Sub

Sub RunDemo()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roScreen", true)
  screen.SetMessagePort(port)
  
  white = &hFFFFFFFF
  blue = &h0000FFFF
  registry = CreateObject("roFontRegistry")
  font = registry.GetDefaultFont()
  While True
    now = CreateObject("roDateTime")
    text = Stri(now.GetHours()) + ":" + Stri(now.GetMinutes()) + ":" + Stri(now.GetSeconds())
    w = font.GetOneLineWidth(text, screen.GetWidth())
    h = font.GetOneLineHeight()
    x = 200
    y = 100
    border = 8
    screen.Clear(&h999999FF)
    screen.DrawRect(x, y, w + 2 * border, h + 2 * border, blue)
    screen.DrawText(text, x + border, y + border, white, font)
    screen.SwapBuffers()
    msg = wait(1000, screen.GetMessagePort())
    if type(msg) = "roUniversalControlEvent"
      button = msg.GetInt()
      if button = 0  'Back button
        exit while
      end if
    end if
  end while
End Sub

Sub Main()
  
  'Initialize theme attributes
  app = CreateObject("roAppManager")
  theme = CreateObject("roAssociativeArray")
  theme.OverhangOffsetSD_X = "72"
  theme.OverhangOffsetSD_Y = "25"
  theme.OverhangSliceSD = "pkg:/images/Overhang_BackgroundSlice_Blue_SD43.png"
  theme.OverhangLogoSD = "pkg:/images/Logo_Overhang_Roku_SDK_SD43.png"
  theme.OverhangOffsetHD_X = "123"
  theme.OverhangOffsetHD_Y = "48"
  theme.OverhangSliceHD = "pkg:/images/Overhang_BackgroundSlice_Blue_HD.png"
  theme.OverhangLogoHD = "pkg:/images/Logo_Overhang_Roku_SDK_HD.png"
  app.SetTheme(theme)
  
  'Display screen
  port = CreateObject("roMessagePort")
  screen = CreateObject("roParagraphScreen")
  screen.SetMessagePort(port)
  screen.SetTitle("Title Text")
  screen.AddHeaderText("Header Text")
  info = CreateObject("roDeviceInfo")
  screen.AddParagraph("[" + info.GetModel() + "|" + info.GetDisplayType() + "|" + info.GetDisplayMode() + "|" + info.GetModelDisplayName() + "|" + Stri(info.GetDisplaySize()["w"]) + "x" + Stri(info.GetDisplaySize()["h"]) + "]")
  screen.AddParagraph("{" + info.GetIPAddrs()["eth1"] + "}")
  now = CreateObject("roDateTime")
  screen.AddParagraph(now.AsDateString("long-date") + " " + Stri(now.GetHours()) + ":" + Stri(now.GetMinutes()) + ":" + Stri(now.GetSeconds()))
  'hostURL = "http://rokudev.roku.com/rokudev/testpatterns/"
  'graphicURL = hostURL + "1280x720" + "/SMPTE_bars_setup_labels_lg.jpg"
  'screen.AddGraphic(graphicURL, "scale-to-fit")
  screen.AddButton(3, "Demo")
  screen.AddButton(2, "Alert")
  screen.AddButton(1, "Close")
  screen.Show()
  
  'Event loop
  transfer = CreateObject("roUrlTransfer")
  transfer.SetMessagePort(port)
  transfer.SetUrl("http://www.example.com/")
  transfer.AsyncGetToString()
  while true
    msg = wait(0, screen.GetMessagePort())
    if type(msg) = "roParagraphScreenEvent"
      if msg.isButtonPressed()
        if msg.GetIndex() = 1
          screen.Close()
        else if msg.GetIndex() = 2
          ShowMessageDialog()
        else if msg.GetIndex() = 3
          RunDemo()
        endif
      else if msg.isScreenClosed()
        return
      endif
    else if type(msg) = "roUrlEvent"
      if msg.GetInt() = 1
        if msg.GetResponseCode() = 200
          headers = msg.GetResponseHeadersArray()
          for each header in headers
            for each key in header
              print "" + key + " = " + header[key]
            end for
          end for
          print msg.GetString()
        else
          print msg.elseGetFailureReason()
        end if
      end if
    endif
  end while
  
End Sub
