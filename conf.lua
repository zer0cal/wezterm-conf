local wezterm = require("wezterm")
local config = {}

local rp_colors = {
	base = "#191724",
	love = "#eb6f92",
	text = "#908caa",
	overlay = "#26233a",
	rose = "#ebbcba",
	pine = "#31748f",
}

config.window_decorations = "NONE"
-- shell
config.default_prog = { "nu", "-l" }

-- Leader Key:
-- The leader key is set to ALT + q, with a timeout of 2000 milliseconds (2 seconds).
-- To execute any keybinding, press the leader key (ALT + q) first, then the corresponding key.
config.leader = { key = "q", mods = "ALT", timeout_miliseconds = 2000 }

-- alt-tab
local tab_history = {}

wezterm.on("update-tab-history", function(window, _)
	local tab = window:active_tab()
	if tab then
		local tab_id = tab:tab_id()
		-- Dodaj ID zakładki do historii, jeśli go tam jeszcze nie ma
		if #tab_history == 0 or tab_history[#tab_history] ~= tab_id then
			table.insert(tab_history, tab_id)
		end

		-- Utrzymuj historię tylko dwóch ostatnich zakładek
		if #tab_history > 2 then
			table.remove(tab_history, 1)
		end
	end
end)

wezterm.on("switch-to-last-tab", function(window, pane)
	if #tab_history >= 2 then
		-- Przełącz na przedostatnią zakładkę
		local last_tab_id = tab_history[#tab_history - 1]
		window:perform_action(wezterm.action.ActivateTab(last_tab_id), pane)
	end
end)

-- Keybindings:
config.keys = {
	-- LEADER + t: Create a new tab in the current pane's domain.
	-- LEADER + q: Close the current pane (with confirmation).
	-- LEADER + b: Switch to the previous tab.
	-- LEADER + n: Switch to the next tab.
	-- LEADER + <number>: Switch to a specific tab (0–9).
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
		mods = "ALT",
		key = "Tab",
		action = wezterm.action.EmitEvent("switch-to-last-tab"),
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
config.color_scheme = "rose-pine"

-- tab_bar
config.enable_tab_bar = true
config.integrated_title_button_style = "Windows"
config.use_fancy_tab_bar = false
config.colors = {
	tab_bar = {
		background = rp_colors.base,
		active_tab = {
			bg_color = rp_colors.base,
			fg_color = rp_colors.love,
		},
		inactive_tab_hover = {
			bg_color = rp_colors.overlay,
			fg_color = rp_colors.text,
		},
		inactive_tab = {
			bg_color = rp_colors.base,
			fg_color = rp_colors.text,
		},
		new_tab_hover = {
			bg_color = rp_colors.overlay,
			fg_color = rp_colors.text,
		},
		new_tab = {
			bg_color = rp_colors.base,
			fg_color = rp_colors.text,
		},
	},
}

wezterm.on("update-right-status", function(window, _)
	local prefix = ""

	if window:leader_is_active() then
		prefix = " L "
		-- SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	end

	window:set_left_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = rp_colors.rose } },
		{ Foreground = { Color = rp_colors.base } },
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
	active_titlebar_bg = rp_colors.base,
	inactive_titlebar_bg = rp_colors.base,
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
