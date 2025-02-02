local wezterm = require("wezterm")
local config = {}

local colors = {
	bg = "#1a1b26",
	text = "#c0caf5",
	comment = "565f89",
	overlay = "#16161e",
	red = "#f7768e",
	rose = "#ff9e64",
	orange = "#f7768e",
}

config.initial_cols = 110
config.initial_rows = 30

config.window_decorations = "NONE"
-- shell
config.default_prog = { "nu", "-l" }

-- Leader Key:
-- The leader key is set to ALT + q, with a timeout of 2000 milliseconds (2 seconds).
-- To execute any keybinding, press the leader key (ALT + q) first, then the corresponding key.
config.leader = { key = "q", mods = "ALT", timeout_miliseconds = 2000 }

-- Keybindings:
config.keys = {
	-- LEADER + t: Create a new tab in the current pane's domain.
	-- LEADER + q: Close the current pane (with confirmation).
	-- LEADER + b: Switch to the previous tab.
	-- LEADER + n: Switch to the next tab.
	{
		mods = "LEADER",
		key = "t",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "LEADER",
		key = "q",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		mods = "LEADER",
		key = "Tab",
		action = wezterm.action.EmitEvent("switch-to-last-tab"),
	},
	{
		mods = "LEADER",
		key = "1",
		action = wezterm.action.ActivateTab(0),
	},
	{
		mods = "LEADER",
		key = "2",
		action = wezterm.action.ActivateTab(1),
	},
	{
		mods = "LEADER",
		key = "3",
		action = wezterm.action.ActivateTab(2),
	},
	{
		mods = "LEADER",
		key = "4",
		action = wezterm.action.ActivateTab(3),
	},
	{
		mods = "LEADER",
		key = "5",
		action = wezterm.action.ActivateTab(4),
	},
	{
		mods = "LEADER",
		key = "6",
		action = wezterm.action.ActivateTab(5),
	},
	{
		mods = "LEADER",
		key = "7",
		action = wezterm.action.ActivateTab(6),
	},
	{
		mods = "LEADER",
		key = "b",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "LEADER",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	-- LEADER + |: Split the current pane horizontally into two panes.
	-- LEADER + -: Split the current pane vertically into two panes.
	{
		mods = "LEADER",
		key = "|",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "-",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- LEADER + h: Move to the pane on the left.
	-- LEADER + j: Move to the pane below.
	-- LEADER + k: Move to the pane above.
	-- LEADER + l: Move to the pane on the right.
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "LEADER",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "LEADER",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	-- LEADER + LeftArrow: Increase the pane size to the left by 5 units.
	-- LEADER + RightArrow: Increase the pane size to the right by 5 units.
	-- LEADER + DownArrow: Increase the pane size downward by 5 units.
	-- LEADER + UpArrow: Increase the pane size upward by 5 units.
	{
		mods = "LEADER",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "LEADER",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "LEADER",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "LEADER",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
}

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
			fg_color = colors.red,
		},
		inactive_tab_hover = {
			bg_color = colors.overlay,
			fg_color = colors.text,
		},
		inactive_tab = {
			bg_color = colors.bg,
			fg_color = colors.text,
		},
		new_tab_hover = {
			bg_color = colors.overlay,
			fg_color = colors.text,
		},
		new_tab = {
			bg_color = colors.bg,
			fg_color = colors.text,
		},
	},
}

-- wezterm.on("gui-startup", function(cmd)
-- 	local args = {}
-- 	if cmd then
-- 		args = cmd.args
-- 	end
-- 	local tab, pane, window = mux.spawn_window({
-- 		cwd = args[0],
-- 	})
-- end)

config.status_update_interval = 100

local tab_history = {}
wezterm.on("update-right-status", function(window, _)
	local tab = window:active_tab()
	if tab then
		local tab_id = tab:tab_id()

		if #tab_history == 0 then
			table.insert(tab_history, tab_id)
		end

		if #tab_history == 1 and tab_history[1] ~= tab_id then
			table.insert(tab_history, tab_id)
		end

		if #tab_history == 2 and tab_history[2] ~= tab_id then
			table.remove(tab_history, 1)
			table.insert(tab_history, tab_id)
		end

		if #tab_history > 2 then
			table.remove(tab_history, 1)
		end
	end
end)

wezterm.on("update-right-status", function(window, _)
	local prefix = " > "
	local bg = colors.bg
	local fg = colors.comment

	if window:leader_is_active() then
		prefix = " L "
		bg = colors.rose
		fg = colors.bg
	end

	window:set_left_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = prefix },
	}))
end)

wezterm.on("switch-to-last-tab", function(window, pane)
	if #tab_history >= 2 then
		-- Przełącz na przedostatnią zakładkę
		local last_tab_id = tab_history[#tab_history - 1]
		window:perform_action(wezterm.action.ActivateTab(last_tab_id), pane)
	end
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
-- config.window_background_opacity = 0
-- config.win32_system_backdrop = "Tabbed"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- font
config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = "Medium" })
config.font_size = 15.0

return config
