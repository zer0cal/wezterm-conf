local wezterm = require("wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local config = {}
local keys = {}
local mux = wezterm.mux
local act = wezterm.action

local tokyonight = {
	background = "#1a1b26",
	foreground = "#a9b1d6",
	text = "#9aa6ce",
	comment = "#565f89",
	terminal_white = "#c0caf5",
	terminal_black = "#414868",
	black = "#32344a",
	white = "#787c99",
	purple = "#bb9af7",
	blue = "#7aa2f7",
	light_blue = "#7dcfff",
	teal_b = "#2ac3de",
	light_teal = "#b4f9f8",
	teal_g = "#73daca",
	green = "#9ece6a",
	yellow = "#cfc9c2",
	light_orange = "#e0af68",
	orange = "#ff9e64",
	red = "#f7768e",
	magenta = "#ad8ee6",
}

local colors = {
	"#bb9af7",
	"#7aa2f7",
	"#7dcfff",
	"#2ac3de",
	"#b4f9f8",
	"#73daca",
	"#9ece6a",
	"#cfc9c2",
	"#e0af68",
	"#ff9e64",
	"#f7768e",
	"#ad8ee6",
}

config.initial_cols = 110
config.initial_rows = 30
config.status_update_interval = 100
config.window_decorations = "NONE"

-- shell
config.default_prog = { "nu", "-l" }

config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

-- Leader Key:
config.leader = { key = "q", mods = "ALT", timeout_miliseconds = 2000 }

-- Keybindings:
table.insert(keys, { mods = "LEADER", key = "t", action = act.SpawnTab("CurrentPaneDomain") })
table.insert(keys, { mods = "LEADER", key = "q", action = act.CloseCurrentPane({ confirm = true }) })
table.insert(keys, { mods = "LEADER", key = "Q", action = act.CloseCurrentTab({ confirm = true }) })
table.insert(keys, { mods = "LEADER", key = "1", action = act.ActivateTab(0) } )
table.insert(keys, { mods = "LEADER", key = "2", action = act.ActivateTab(1) } )
table.insert(keys, { mods = "LEADER", key = "3", action = act.ActivateTab(2) } )
table.insert(keys, { mods = "LEADER", key = "4", action = act.ActivateTab(3) } )
table.insert(keys, { mods = "LEADER", key = "5", action = act.ActivateTab(4) } )
table.insert(keys, { mods = "LEADER", key = "6", action = act.ActivateTab(5) } )
table.insert(keys, { mods = "LEADER", key = "7", action = act.ActivateTab(6) } )
table.insert(keys, { mods = "LEADER", key = "8", action = act.ActivateTab(7) } )
table.insert(keys, { mods = "LEADER", key = "9", action = act.ActivateTab(8) } )
table.insert(keys, { mods = "LEADER", key = "0", action = act.ActivateTab(9) } )
table.insert(keys, { mods = "LEADER", key = "\\", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { mods = "LEADER", key = "-", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) })
table.insert(keys, { mods = "LEADER", key = "h", action = act.ActivatePaneDirection("Left") })
table.insert(keys, { mods = "LEADER", key = "j", action = act.ActivatePaneDirection("Down") })
table.insert(keys, { mods = "LEADER", key = "k", action = act.ActivatePaneDirection("Up") })
table.insert(keys, { mods = "LEADER", key = "l", action = act.ActivatePaneDirection("Right") })
table.insert(keys, { mods = "LEADER", key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 5 }) })
table.insert(keys, { mods = "LEADER", key = "RightArrow", action = act.AdjustPaneSize({ "Right", 5 }) })
table.insert(keys, { mods = "LEADER", key = "DownArrow", action = act.AdjustPaneSize({ "Down", 5 }) })
table.insert(keys, { mods = "LEADER", key = "UpArrow", action = act.AdjustPaneSize({ "Up", 5 }) })

-- theme
config.color_scheme = "Tokyo Night"

-- tab_bar
config.enable_tab_bar = true
config.integrated_title_button_style = "Windows"
config.use_fancy_tab_bar = false
config.tab_max_width = 60

config.colors = {
	tab_bar = {
		background = tokyonight.background,
		active_tab = {
			bg_color = tokyonight.background,
			fg_color = tokyonight.light_teal,
		},
		inactive_tab_hover = {
			bg_color = tokyonight.black,
			fg_color = tokyonight.comment,
		},
		inactive_tab = {
			bg_color = tokyonight.background,
			fg_color = tokyonight.comment,
		},
		new_tab_hover = {
			bg_color = tokyonight.black,
			fg_color = tokyonight.comment,
		},
		new_tab = {
			bg_color = tokyonight.background,
			fg_color = tokyonight.comment,
		},
	},
}

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    return ' [' .. tab.tab_index + 1 .. '] ' .. tab.active_pane.title .. ' '
  end
)

-- workspce
workspace_switcher.zoxide_path = "~/AppData/Local/Microsoft/WinGet/Packages/ajeetdsouza.zoxide_Microsoft.Winget.Source_8wekyb3d8bbwe"
local workspace_switch_is_active = false
local workspace_create_is_active = false
local workspace_delete_is_active = false
local workspace_resurrect_is_active = false

table.insert(keys, { mods = "LEADER", key = "s", action = workspace_switcher.switch_workspace() })
table.insert(keys, { mods = "LEADER", key = "[", action = act.SwitchWorkspaceRelative(1) })
table.insert(keys, { mods = "LEADER", key = "]", action = act.SwitchWorkspaceRelative(-1) })

table.insert(keys, {
	mods = "LEADER",
	key = "c",
	action = act.Multiple {
	act.EmitEvent ("open-new-workspace-prompt"),
	act.PromptInputLine({
		description = "Enter name for new workspace",
		action = wezterm.action_callback(function(window, pane, line)
			workspace_create_is_active = false
			if line then
				window:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane)
			end
		end)
		})
}})

table.insert(keys, {
	mods = "LEADER",
	key = "w",
	action = wezterm.action_callback(function(_, _)
  	resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
    resurrect.window_state.save_window_action()
  end),
})

table.insert(keys, {
	mods = "LEADER",
	key = "d",
	action = wezterm.action_callback(function(win, pane)
		workspace_delete_is_active = true
    resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
        resurrect.state_manager.delete_state(id)
      end,
      {
        title = "Delete State",
        description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
        fuzzy_description = "Search State to Delete: ",
        is_fuzzy = true,
	    }
	  )
	end),
})

table.insert(keys, { mods = "LEADER", key = "r", action = wezterm.action_callback(function(win, pane)
	workspace_resurrect_is_active = true
  resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, _)
		local type = string.match(id, "^([^/]+)") -- match before '/'
    id = string.match(id, "([^/]+)$") -- match after '/'
    id = string.match(id, "(.+)%..+$") -- remove file extention
    local opts = {
    	spawn_in_workspace = true,
      relative = true,
      restore_text = true,
      on_pane_restore = resurrect.tab_state.default_on_pane_restore,
    }
    if type == "workspace" then
      local state = resurrect.state_manager.load_state(id, "workspace")
      resurrect.workspace_state.restore_workspace(state, opts)
		  mux.set_active_workspace(id)
    elseif type == "window" then
      local state = resurrect.state_manager.load_state(id, "window")
      resurrect.window_state.restore_window(pane:window(), state, opts)
		  mux.set_active_workspace(id)
    elseif type == "tab" then
      local state = resurrect.state_manager.load_state(id, "tab")
      resurrect.tab_state.restore_tab(pane:tab(), state, opts)
		  mux.set_active_workspace(id)
    end
   end)
end)})

wezterm.on("resurrect.fuzzy_loader.fuzzy_load.finished", function(_, _)
	workspace_resurrect_is_active = false
	workspace_delete_is_active = false
end)

wezterm.on("open-new-workspace-prompt", function(_, _) workspace_create_is_active = true end)

local function hash(str)
    local h = 5381

    for i = 1, #str do
       h = h*32 + h + str:byte(i)
    end
    return h
end

wezterm.on("update-right-status", function(window, _)
	local active_workspace = window:active_workspace()
	local num = (hash(active_workspace) % #colors) + 1
	local bg = colors[num]
	local overrides = {
		colors =  {
			tab_bar = {
				active_tab = {
					bg_color = tokyonight.background,
					fg_color = bg,
				},
			},
		}
	}

	window:set_config_overrides(overrides)

	window:set_right_status(wezterm.format({
	  { Attribute = { Intensity = "Bold" } },
		{ Background = { Color = bg } },
		{ Foreground = { Color = tokyonight.background } },
		{ Text = " " .. active_workspace .. " " },
	}))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.start", function(_, _) workspace_switch_is_active = true end)
wezterm.on("smart_workspace_switcher.workspace_switcher.canceled", function(_, _) workspace_switch_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(_, _) workspace_switch_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(_, _) workspace_switch_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(_, _) workspace_switch_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.switched_to_prev", function(_, _) workspace_switch_is_active = false end)

-- leader indicator
wezterm.on("update-right-status", function(window, _)
	local prefix = " > "
	local bg = tokyonight.background
	local fg = tokyonight.comment

	if window:leader_is_active() then
		prefix = " L "
		bg = tokyonight.blue
		fg = tokyonight.background
	end

	if workspace_switch_is_active then
		prefix = " S "
		bg = tokyonight.orange
		fg = tokyonight.background
	end

	if workspace_create_is_active then
		prefix = " C "
		bg = tokyonight.green
		fg = tokyonight.background
	end

	if workspace_delete_is_active then
		prefix = " D "
		bg = tokyonight.red
		fg = tokyonight.background
	end

	if workspace_resurrect_is_active then
		prefix = " R "
		bg = tokyonight.teal_g
		fg = tokyonight.background
	end

	window:set_left_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = prefix },
	}))
end)

-- window
config.window_frame = {
	font = wezterm.font({ family = "JetBrainsMono Nerd Font Mono", weight = "Bold" }),
	font_size = 10.0,
	border_left_width = "0px",
	border_right_width = "0px",
	border_bottom_height = "0px",
	border_top_height = "0px",
	active_titlebar_bg = colors.base,
	inactive_titlebar_bg = colors.base,
}

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- font
config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Bold" })
config.font_size = 15.0

config.keys = keys

return config
