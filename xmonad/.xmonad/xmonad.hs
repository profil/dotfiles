import XMonad
import XMonad.Config.Desktop
import XMonad.Layout.Spacing

main = xmonad desktopConfig
    { terminal = "alacritty"
    , modMask = mod4Mask
    , borderWidth = 5
    , normalBorderColor = "#282a36"
    , focusedBorderColor = "#bd93f9"
    , layoutHook = spacing 10 $ Tall 1 (3/100) (3/5) ||| Full
    }
