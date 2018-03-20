import Data.Maybe
import Control.Monad

import qualified Data.Map as M
import qualified XMonad.StackSet as W

import XMonad

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers

import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders
import XMonad.Layout.SimplestFloat

import XMonad.Util.Scratchpad
import XMonad.Util.Cursor

import Graphics.X11.ExtraTypes.XF86

main = xmonad =<< xmobar myConfig

myConfig = ewmh def
  {terminal = "alacritty",
   modMask = mod4Mask,
   borderWidth = 2,
   normalBorderColor = "#343C48",
   focusedBorderColor = "#6986a0",
   startupHook = setDefaultCursor xC_left_ptr >> addEWMHFullscreen,
   workspaces = myWorkspaces,
   layoutHook = myLayouts,
   keys = keys def <+> myKeys,
   manageHook = manageHook def <+> myManageHook,
   handleEventHook = handleEventHook def <+> fullscreenEventHook}

myWorkspaces = ["web", "steam", "other"]

myLayouts = onWorkspace "steam" (noBorders simplestFloat) $
            spacingWithEdge 5 $
            smartBorders $
            Tall 1 (3/100) (3/5) ||| Full

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
  [((modm, xK_section), scratchpadSpawnActionCustom "alacritty -d 0 0 -t scratchpad"),
   ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%"),
   ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%"),
   ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")]

myManageHook = composeAll
  [className =? "Steam" --> doShift "steam",
   className =? "Pavucontrol" --> doCenterFloat,
   className =? "dota2" --> doCenterFloat,
   className =? "mpv" --> doCenterFloat,
   className =? "Xmessage" --> doCenterFloat,
   scratchpadManageHook (W.RationalRect 0.2 0.2 0.6 0.6)]

addNETSupported x = withDisplay $ \dpy -> do
  r               <- asks theRoot
  a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
  a               <- getAtom "ATOM"
  liftIO $ do
    sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
    when (fromIntegral x `notElem` sup) $
      changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen   = do
  wms <- getAtom "_NET_WM_STATE"
  wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
  mapM_ addNETSupported [wms, wfs]
