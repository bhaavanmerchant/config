-- Import stuff
import XMonad
import qualified XMonad.StackSet as W
import qualified XMonad.StackSet as Z
import qualified Data.Map as M
import Data.Monoid
import XMonad.Util.EZConfig(additionalKeys)
import System.Exit
import Graphics.X11.Xlib
import System.IO

-- actions
import XMonad.Actions.CycleWS
import XMonad.Actions.WindowGo
import qualified XMonad.Actions.Submap as SM
import XMonad.Actions.GridSelect
import XMonad.Actions.FloatKeys
import XMonad.Actions.Submap

-- utils
import XMonad.Util.NamedScratchpad
import XMonad.Util.Scratchpad

import XMonad.Util.Run(spawnPipe)
import qualified XMonad.Prompt as P
import XMonad.Prompt.Shell
import XMonad.Prompt
import XMonad.Prompt.AppendFile (appendFilePrompt)
import XMonad.Prompt.RunOrRaise


-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageHelpers

-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Reflect
import XMonad.Layout.IM
import XMonad.Layout.Tabbed
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Grid
import Control.OldException(catchDyn,try)

-- Data.Ratio for IM layout
import Data.Ratio ((%))


-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "urxvt"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The mask for the numlock key. Numlock status is "masked" from the
-- current modifier status, so the keybindings will work with numlock on or
-- off. You may need to change this on some systems.
--
-- You can find the numlock modifier by running "xmodmap" and looking for a
-- modifier with Num_Lock bound to it:
--
-- > $ xmodmap | grep Num
-- > mod2        Num_Lock (0x4d)
--
-- Set numlockMask = 0 if you don't have a numlock key, or want to treat
-- numlock status separately.
--
myNumlockMask   = mod2Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["Verbose","Web","DC","IRC","Music","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"



main = do
    	xmproc <- spawnPipe "xmobar"
	xmonad 	$ defaultConfig
        	{ terminal           = myTerminal
        	, focusFollowsMouse  = myFocusFollowsMouse
        	, borderWidth        = myBorderWidth
        	, modMask            = myModMask
        	, numlockMask        = myNumlockMask
        	, workspaces         = myWorkspaces
        	, normalBorderColor  = myNormalBorderColor
        	, focusedBorderColor = myFocusedBorderColor
        	-- key bindings
        	, keys               = myKeys
        	, mouseBindings      = myMouseBindings
        	-- hooks, layouts
        	, layoutHook         = myLayout
        	, manageHook         = myManageHook
        	, handleEventHook    = myEventHook
        	, logHook            = myLogHook xmproc
        	, startupHook        = myStartupHook
        	}










------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)


    , ((modm,               xK_Right),  nextWS)
    , ((modm,               xK_Left),    prevWS)
    , ((modm .|. shiftMask, xK_Right), shiftToNext >> nextWS)
    , ((modm .|. shiftMask, xK_Left),   shiftToPrev >> prevWS)
    , ((modm,               xK_z),     toggleWS)


     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)






    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_Down     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_Up     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm .|. shiftMask, xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )






    -- Shrink the master area
    , ((modm .|. shiftMask, xK_comma ), sendMessage Shrink)

    -- Expand the master area
    , ((modm .|. shiftMask, xK_period), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)



    -- volume control
    , ((0 , 0x1008ff13 ), spawn "amixer -q set Master 5%+ ")
    , ((0 , 0x1008ff11 ), spawn "amixer -q set Master 5%- ")
    , ((0 , 0x1008ff12 ), spawn "amixer -q set Master toggle")


    --MPD
    , ((0 , 0x1008ff16 ), spawn "mpc prev")
    , ((0 , 0x1008ff14 ), spawn "mpc toggle")
    , ((0 , 0x1008ff17 ), spawn "mpc next")
    , ((0 , 0x1008ff15 ), spawn "mpc stop")



    --Desktop
    , ((0 , 0x1008ff19 ), spawn "firefox www.gmail.com")
    , ((0 , 0x1008ff18 ), spawn "rox")



    --Lauchers
    , ((modm,               xK_f     ), spawn "urxvtc -e firefox; notify-send Firefox initiated --icon=/usr/lib/firefox-4.0/icons/mozicon128.png")
    , ((modm,               xK_d     ), spawn "urxvtc -e eiskaltdcpp-qt; notify-send EiskaltDC initiated --icon=/usr/share/eiskaltdcpp/qt/icons/appl/default/icon_appl_big.png")
    , ((modm,               xK_c     ), spawn "urxvtc -e xcompmgr; notify-send Xcompmgr initiated --icon=/root/.icons/tux-icon.png")







    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
--

myLayout = standardLayouts 
   where
        standardLayouts =   avoidStruts  $ (tiled |||  reflectTiled ||| Mirror tiled ||| Grid ||| Full)
 
        --Layouts
        tiled     = smartBorders (ResizableTall 1 (2/100) (1/2) [])
        reflectTiled = (reflectHoriz tiled)
        full      = noBorders Full






------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook :: ManageHook
myManageHook = composeAll
    [ className =? "Firefox"        --> doShift "Web"
    , className =? "XChat"	    --> doShift "IRC"
    , className =? "Eiskaltdcpp-qt"    --> doShift "DC"
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--logHook
--logHook
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ customPP { ppOutput = hPutStrLn h }
 
 
 
---- Looks --
---- bar
customPP :: PP
customPP = defaultPP { 
     			    ppHidden = xmobarColor "#FFFF00" ""
			  , ppCurrent = xmobarColor "#FFFF00" "" . wrap "[" "]"
			  , ppUrgent = xmobarColor "#FF0000" "" . wrap "*" "*"
                          , ppLayout = xmobarColor "#000000" "" . shorten 0
                          , ppTitle = xmobarColor "#FFFFFF" "" . shorten 80
                          , ppSep = "<fc=#0033FF> | </fc>"
                     }



------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

