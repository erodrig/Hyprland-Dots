-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User keybind overrides (auto-generated).
-- Add, override, or rebind keybinds with bind("MODS", "KEY", fn, opts) and unbind("MODS", "KEY").
--
-- 1. ADDING A NEW KEYBIND (combo not used by default):
--    bind("SUPER", "Z", exec_cmd("ghostty"), { description = "Launch Ghostty" })
--    bind("SUPER SHIFT", "V", exec_cmd("pavucontrol"), { description = "Audio Control" })
--
-- 2. OVERRIDING AN EXISTING COMBO WITH A DIFFERENT APP/COMMAND:
--    unbind("SUPER", "Return")
--    bind("SUPER", "Return", exec_cmd("ghostty"), { description = "Launch Ghostty" })
--
-- 3. REBINDING AN ACTION TO A NEW KEY COMBINATION:
--    unbind("SUPER", "E")
--    unbind("SUPER", "F")
--    bind("SUPER", "F", exec_cmd("$HOME/.config/hypr/scripts/LaunchFileManager.sh '$files' '$term'"), { description = "File manager" })
--    bind("SUPER", "E", exec_cmd("emacsclient -c -a 'emacs'"), { description = "Launch Emacs" })
--
-- 4. REBINDING DISPATCHERS (e.g. killactive, workspace):
--    unbind("SUPER", "Q")
--    bind("SUPER", "Q", dispatch("killactive"), { description = "Close active window" })
--
-- 5. BIND OPTIONS (locked, repeating):
--    bind("CTRL ALT", "bracketright", exec_cmd("$HOME/.config/hypr/scripts/Brightness.sh --inc"), { description = "Brightness up", repeating = true })
--    bind("", "XF86AudioMute", exec_cmd("$HOME/.config/hypr/scripts/Volume.sh --toggle"), { description = "Mute audio", locked = true })
--
-- Helper functions live in ${XDG_CONFIG_HOME:-$HOME/.config}/hypr/lua/user_keybinds_helper.lua so they can be updated separately.
local user_keybinds_helper = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/../lua/user_keybinds_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/user_keybinds_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/user_keybinds_helper.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.bind then
          user_keybinds_helper = loaded_helpers
          break
        end
      end
    end
  end

  if not user_keybinds_helper then
    error("Failed to load user_keybinds_helper.lua from: " .. table.concat(tried_paths, ", "))
  end
end
local exec_cmd = user_keybinds_helper.exec_cmd
local dispatch = user_keybinds_helper.dispatch
local bind = user_keybinds_helper.bind
local unbind = user_keybinds_helper.unbind

-- Converted from UserKeybinds.conf
bind("SUPER", "V", exec_cmd("$HOME/.config/hypr/scripts/nerd-dictation-toggle.sh"))
bind("SUPER ALT", "F", dispatch("fullscreen", ""), { description = "fullscreen" })
unbind("SUPER", "SPACE")
bind("SUPER", "SPACE", exec_cmd("pkill rofi || true && rofi -show drun -modi drun, filebrowser, run, window"), { description = "app launcher" })
unbind("SUPER ALT", "SPACE")
bind("SUPER ALT", "SPACE", exec_cmd("hyprctl dispatch workspaceopt allfloat"), { description = "Float all windows" })
unbind("SUPER SHIFT", "F")
bind("SUPER SHIFT", "F", dispatch("togglefloating", ""), { description = "Float current window" })
unbind("SUPER", "D")
bind("SUPER", "D", dispatch("pseudo", ""), { description = "toggle pseudo (dwindle)" })
unbind("SUPER SHIFT", "Return")
bind("SUPER SHIFT", "Return", exec_cmd("$HOME/.config/hypr/scripts/Dropterminal.sh $term"), { description = "DropDown terminal" })
unbind("SUPER", "Tab")
unbind("SUPER", "tab")
unbind("SUPER SHIFT", "Tab")
unbind("SUPER SHIFT", "tab")
bind("SUPER", "Tab", dispatch("changegroupactive", "f"), { description = "Change Group Forward" })
bind("SUPER SHIFT", "Tab", dispatch("changegroupactive", "b"), { description = "Change Group Back" })
unbind("SUPER", "U")
unbind("SUPER SHIFT", "U")
-- hl.dsp.exec_raw("togglespecialworkspace") returns ok but silently does nothing,
-- so the generic dispatch() path cannot express this one. Call the API directly.
bind("SUPER", "X", function() hl.dispatch(hl.dsp.workspace.toggle_special()) end, { description = "toggle special workspace" })
bind("SUPER SHIFT", "X", dispatch("movetoworkspace", "special"), { description = "move to special workspace" })
unbind("SUPER", "P")
bind("SUPER", "P", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --now"), { description = "screenshot now" })
bind("SUPER SHIFT", "P", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --area"), { description = "screenshot (area)" })
bind("SUPER CTRL", "P", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in5"), { description = "screenshot in 5s" })
bind("SUPER CTRL SHIFT", "P", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --in10"), { description = "screenshot in 10s" })
bind("ALT", "P", exec_cmd("$HOME/.config/hypr/scripts/ScreenShot.sh --active"), { description = "screenshot active window" })
bind("SUPER SHIFT", "Slash", exec_cmd("$HOME/.config/hypr/scripts/Dropmusic.sh"), { description = "Dropdown Music" })
bind("SUPER", "Z", exec_cmd("hyprctl keyword cursor:zoom_factor \"$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {if ($2 <= 1.1) print 2.0; else print 1.0}')\""), { description = "Toggle zoom" })
