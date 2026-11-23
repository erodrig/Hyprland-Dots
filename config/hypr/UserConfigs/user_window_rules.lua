-- ==================================================
--  KoolDots (2026)
--  Project URL: https://github.com/LinuxBeginnings
--  License: GNU GPLv3
--  SPDX-License-Identifier: GPL-3.0-or-later
-- ==================================================

-- User window rule overrides (auto-generated).
-- Add your own rules with apply_window_rule({...})
-- Example:
-- apply_window_rule({
--   name = "My Float Rule",
--   match = { class = "^pavucontrol$" },
--   float = true,
--   center = true,
-- })

local user_window_rules_helper = nil
do
  local source = (debug.getinfo(1, "S") or {}).source or ""
  local source_path = source:match("^@(.+)$")
  local source_dir = source_path and source_path:match("^(.*)/[^/]+$") or nil
  local home = os.getenv("HOME") or ""
  local candidate_paths = {
    source_dir and (source_dir .. "/../lua/user_window_rules_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/lua/user_window_rules_helper.lua") or nil,
    home ~= "" and (home .. "/.config/hypr/user_window_rules_helper.lua") or nil,
  }

  local tried_paths = {}
  for _, helper_path in ipairs(candidate_paths) do
    if helper_path then
      table.insert(tried_paths, helper_path)
      local f = io.open(helper_path, "r")
      if f then
        f:close()
        local loaded_ok, loaded_helpers = pcall(dofile, helper_path)
        if loaded_ok and type(loaded_helpers) == "table" and loaded_helpers.apply_window_rule then
          user_window_rules_helper = loaded_helpers
          break
        end
      end
    end
  end

  if not user_window_rules_helper then
    error("Failed to load user_window_rules_helper.lua from: " .. table.concat(tried_paths, ", "))
  end
end
local apply_window_rule = user_window_rules_helper.apply_window_rule

-- Converted from WindowRules.conf
apply_window_rule({
  name = "user-window-windowrule-001",
  match = {
    class = "^(ZapZap|com.rtosta.zapzap)$",
  },
  tag = "+im",
})

apply_window_rule({
  name = "user-window-windowrule-002",
  match = {
    class = "^([Zz]oom)$",
  },
  tag = "+messaging",
})

apply_window_rule({
  name = "user-window-windowrule-003",
  match = {
    tag = "browser",
  },
  workspace = 1,
})

apply_window_rule({
  name = "user-window-windowrule-004",
  match = {
    tag = "email",
  },
  workspace = 4,
})

apply_window_rule({
  name = "user-window-windowrule-005",
  match = {
    tag = "gamestore",
  },
  workspace = 5,
})

apply_window_rule({
  name = "user-window-windowrule-006",
  match = {
    tag = "messaging",
  },
  workspace = 5,
})

apply_window_rule({
  name = "user-window-windowrule-007",
  match = {
    tag = "im",
  },
  workspace = 7,
})

apply_window_rule({
  name = "user-window-windowrule-008",
  match = {
    tag = "games",
  },
  workspace = 8,
})

apply_window_rule({
  name = "user-window-windowrule-009",
  match = {
    tag = "screenshare",
  },
  workspace = "4 silent",
})

apply_window_rule({
  name = "user-window-windowrule-010",
  match = {
    class = "^(virt-manager)$",
  },
  workspace = "6 silent",
})

apply_window_rule({
  name = "user-window-windowrule-011",
  match = {
    class = "^(.virt-manager-wrapped)$",
  },
  workspace = "6 silent",
})

apply_window_rule({
  name = "user-window-windowrule-012",
  match = {
    tag = "multimedia",
  },
  workspace = "9 silent",
})

apply_window_rule({
  name = "Discord",
  match = {
    class = "^(com\\.discordapp\\.Discord|discord)$",
  },
  workspace = 5,
  float = true,
  opacity = "1.0 0.86",
  size = "(monitor_w*0.45) (monitor_h*0.5)",
})

apply_window_rule({
  name = "Slack",
  match = {
    class = "^(Slack)$",
  },
  workspace = "special",
  tile = true,
})

apply_window_rule({
  name = "Obsidian",
  match = {
    class = "^(obsidian)$",
  },
  workspace = "special",
  tile = true,
})

apply_window_rule({
  name = "Steam-main",
  match = {
    class = "^([Ss]team)$",
    title = "^([Ss]team)$",
  },
  move = "49% 7%",
  size = "(monitor_w*0.5) (monitor_h*0.6)",
})

apply_window_rule({
  name = "ncmpcpp",
  match = {
    class = "^([Nn]cmpcpp)$",
  },
  float = true,
  size = "(monitor_w*0.45) (monitor_h*0.5)",
  move = "50% 50%",
})

apply_window_rule({
  name = "user-window-windowrule-013",
  match = {
    class = "^(code)$",
  },
  opacity = "1.0 0.8",
})
