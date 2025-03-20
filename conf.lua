local wezterm = require("wezterm")
local config = {}
local keys = {}
local mux = wezterm.mux
local act = wezterm.action

local colors = {
	bg = "#1a1b26",
	text = "#c0caf5",
	comment = "565f89",
	overlay = "#16161e",
	red = "#f7768e",
	orange = "#ff9e64",
	red_2 = "#f7768e",
}

config.initial_cols = 110
config.initial_rows = 30

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
config.colors = {
	tab_bar = {
		background = colors.bg,
		active_tab = {
			bg_color = colors.bg,
			fg_color = colors.text,
		},
		inactive_tab_hover = {
			bg_color = colors.overlay,
			fg_color = colors.comment,
		},
		inactive_tab = {
			bg_color = colors.bg,
			fg_color = colors.comment,
		},
		new_tab_hover = {
			bg_color = colors.overlay,
			fg_color = colors.comment,
		},
		new_tab = {
			bg_color = colors.bg,
			fg_color = colors.comment,
		},
	},
}

config.status_update_interval = 100

-- workspce
config.default_workspace = "~"
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
workspace_switcher.zoxide_path = "~/AppData/Local/Microsoft/WinGet/Packages/ajeetdsouza.zoxide_Microsoft.Winget.Source_8wekyb3d8bbwe"
local workspace_switcher_is_active = false

table.insert(keys, { mods = "LEADER", key = "s", action = workspace_switcher.switch_workspace() })
table.insert(keys, { mods = "LEADER", key = "w", action =  wezterm.action.PromptInputLine({
			description = "Enter name for new workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		})})

wezterm.on("update-right-status", function(window, _)
	local active_workspace = window:active_workspace()
	local bg = colors.comment

	if active_workspace ~= "~" then
		bg = colors.red
	end

	window:set_right_status(wezterm.format({
	  { Attribute = { Intensity = "Bold" } },
		{ Background = { Color = bg } },
		{ Foreground = { Color = colors.bg } },
		{ Text = " " .. active_workspace .. " " },
	}))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.start", function(_, _) workspace_switcher_is_active = true end)
wezterm.on("smart_workspace_switcher.workspace_switcher.canceled", function(_, _) workspace_switcher_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(_, _) workspace_switcher_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(_, _) workspace_switcher_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(_, _) workspace_switcher_is_active = false end)
wezterm.on("smart_workspace_switcher.workspace_switcher.switched_to_prev", function(_, _) workspace_switcher_is_active = false end)

-- leader indicator
wezterm.on("update-right-status", function(window, _)
	local prefix = " > "
	local bg = colors.bg
	local fg = colors.comment

	if window:leader_is_active() then
		prefix = " L "
		bg = colors.comment
		fg = colors.bg
	end

	if workspace_switcher_is_active then

		prefix = " W "
		bg = colors.red
		fg = colors.bg
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
