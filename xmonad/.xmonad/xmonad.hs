import qualified Data.Map as M
import qualified XMonad.StackSet as W

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.Spacing
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders
import XMonad.Layout.SimpleFloat
import XMonad.Util.Scratchpad
import XMonad.Util.Cursor

import XMonad.Prompt
import XMonad.Prompt.Theme

import Graphics.X11.ExtraTypes.XF86

main = xmonad =<< xmobar myConfig

myConfig = ewmh defaultConfig
  {terminal = "alacritty",
   modMask = mod4Mask,
   borderWidth = 2,
   normalBorderColor = "#343C48",
   focusedBorderColor = "#6986a0",
   startupHook = setDefaultCursor xC_left_ptr,
   workspaces = myWorkspaces,
   layoutHook = myLayouts,
   keys = keys defaultConfig <+> myKeys,
   manageHook = manageHook defaultConfig <+> myManageHook,
   handleEventHook = handleEventHook defaultConfig <+> fullscreenEventHook}

myWorkspaces = ["web", "steam", "other"]

myLayouts = onWorkspace "steam"
            simpleFloat $
            smartSpacing 10 $
            smartBorders $ Tall 1 (3/100) (3/5) ||| Full

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList
  [((modMask, xK_section), scratchpadSpawnActionCustom "alacritty -d 0 0 -t scratchpad"),
   ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%"),
   ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%"),
   ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")]

myManageHook = composeAll
  [className =? "hl2_linux" --> doShift "steam",
   className =? "Steam" --> doShift "steam",
   className =? "dota2" --> doIgnore,
   className =? "Pavucontrol" --> doCenterFloat,
   scratchpadManageHook (W.RationalRect 0.2 0.2 0.6 0.6)]
