-- ================================================================================================
-- TITLE : Ghostty dashboard
-- ABOUT : Ghostty ASCII dashboard header, animation, positioning, and dashboard-specific UI polish.
-- ================================================================================================

local M = {}

local ghosty_frame = 1
local ghosty_timer
local ghosty_frames
local ghosty_art_ns = vim.api.nvim_create_namespace("ghosty_dashboard_art")
local ghosty_art_state
local pause_dashboard_animation
local resume_dashboard_animation

local ghosty_frame_count = 100
local ghosty_source_width = 100
local ghosty_source_height = 41
local ghosty_pane_gap = 10
local ghosty_dashboard_width = math.max(0, vim.o.columns - 4)
local ghosty_scale = ghosty_dashboard_width >= 160
		and math.min(0.62, (ghosty_dashboard_width - ghosty_pane_gap) / (ghosty_source_width * 2))
	or 0.58
local ghosty_width = math.floor(ghosty_source_width * ghosty_scale + 0.5)
local ghosty_height = math.floor(ghosty_source_height * ghosty_scale + 0.5)
local ghosty_art_width = ghosty_width
local ghosty_title = "GhostyNVIM"
local ghosty_title_padding = { 1, 2 }
local ghosty_title_art = {
	"█▀▀ █░█ █▀█ █▀ ▀█▀ █▄█   █▄░█ █░█ █ █▀▄▀█",
	"█▄█ █▀█ █▄█ ▄█ ░█░ ░█░   █░▀█ ▀▄▀ █ █░▀░█",
}

M.width = ghosty_width
M.pane_gap = ghosty_pane_gap

local function strip_ghostty_html(line)
	return (line:gsub('<span class="b">', ""):gsub("</span>", ""):gsub("·", "."))
end

local function scaled_source_index(index, scale, limit)
	return math.min(limit, math.floor((index - 1) / scale) + 1)
end

local function scale_ghostty_line(line)
	local chars = {}

	for col = 1, ghosty_width do
		local source_col = scaled_source_index(col, ghosty_scale, ghosty_source_width)
		chars[col] = vim.fn.strcharpart(line, source_col - 1, 1)
	end

	local text = table.concat(chars)
	local width = vim.fn.strdisplaywidth(text)
	if width < ghosty_width then
		text = text .. string.rep(" ", ghosty_width - width)
	end

	return text
end

local function scale_ghostty_lines(lines)
	local scaled = {}

	for row = 1, ghosty_height do
		local source_row = scaled_source_index(row, ghosty_scale, #lines)
		scaled[row] = scale_ghostty_line(lines[source_row] or "")
	end

	return scaled
end

local function crop_ghostty_frames(frames)
	local min_col = ghosty_width
	local max_col = 1

	for _, frame in ipairs(frames) do
		for _, line in ipairs(frame) do
			for col = 1, ghosty_width do
				if vim.fn.strcharpart(line, col - 1, 1):match("%S") then
					min_col = math.min(min_col, col)
					max_col = math.max(max_col, col)
				end
			end
		end
	end

	if max_col < min_col then
		return frames
	end

	ghosty_art_width = max_col - min_col + 1
	for frame_index, frame in ipairs(frames) do
		local cropped = {}
		for line_index, line in ipairs(frame) do
			cropped[line_index] = vim.fn.strcharpart(line, min_col - 1, max_col - min_col + 1)
		end
		frames[frame_index] = cropped
	end

	return frames
end

local function load_ghosty_frames()
	if ghosty_frames then
		return ghosty_frames
	end

	local dir = vim.fn.stdpath("config") .. "/assets/ghostty-animation"
	local scaled_frames = {}

	for index = 1, ghosty_frame_count do
		local path = string.format("%s/frame_%03d.txt", dir, index)
		if vim.fn.filereadable(path) == 0 then
			break
		end

		local ok, lines = pcall(vim.fn.readfile, path)
		if not ok then
			break
		end
		if #lines == 0 then
			break
		end

		for line_index, line in ipairs(lines) do
			lines[line_index] = strip_ghostty_html(line)
		end

		scaled_frames[#scaled_frames + 1] = scale_ghostty_lines(lines)
	end

	if #scaled_frames == 0 then
		ghosty_art_width = vim.fn.strdisplaywidth(ghosty_title)
		ghosty_frames = { ghosty_title }
		return ghosty_frames
	end

	ghosty_frames = {}
	for _, frame in ipairs(crop_ghostty_frames(scaled_frames)) do
		ghosty_frames[#ghosty_frames + 1] = table.concat(frame, "\n")
	end

	return ghosty_frames
end

local function ghosty_header()
	local frames = load_ghosty_frames()
	return frames[ghosty_frame]
end

local function ghosty_title_header()
	local lines = {}

	for _, line in ipairs(ghosty_title_art) do
		lines[#lines + 1] = line:gsub("%s+$", "")
	end

	return table.concat(lines, "\n")
end

local function stop_dashboard_animation()
	if ghosty_timer then
		ghosty_timer:stop()
		ghosty_timer:close()
		ghosty_timer = nil
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "snacks_dashboard" then
			vim.api.nvim_buf_clear_namespace(buf, ghosty_art_ns, 0, -1)
		end
	end
	ghosty_art_state = nil
end

local function find_dashboard()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "snacks_dashboard" then
			return win, buf
		end
	end
end

local function dashboard_animation_enabled()
	return vim.g.dashboard_animation ~= false and #vim.api.nvim_list_uis() > 0
end

local function paint_dashboard_background()
	local win, buf = find_dashboard()
	if not win or not buf then
		return
	end

	vim.b[buf].minitrailspace_disable = true
	vim.api.nvim_win_call(win, function()
		pcall(vim.fn.clearmatches, win)
		pcall(function()
			require("mini.trailspace").unhighlight()
		end)
	end)
	vim.wo[win].fillchars = "eob: "
	vim.wo[win].winhighlight =
		"Normal:SnacksDashboardNormal,NormalFloat:SnacksDashboardNormal,EndOfBuffer:SnacksDashboardNormal"
end

local function centered_art_col(pane_col)
	return math.max(0, pane_col + math.floor((ghosty_width - ghosty_art_width) / 2))
end

local function ghosty_title_width()
	local width = 0
	for _, line in ipairs(ghosty_title_art) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	return width
end

local function set_ghosty_art_position(dashboard, pos)
	ghosty_art_state = {
		buf = dashboard.buf,
		start_row = pos[1] - 1,
		col = centered_art_col(pos[2]),
	}
end

local function locate_ghosty_art(buf)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	for index, line in ipairs(lines) do
		local title_start = line:find(ghosty_title_art[1], 1, true)
		if title_start then
			local title_top_padding = ghosty_title_padding[2] or 0
			local start_row = math.max(0, index - title_top_padding - ghosty_height - 1)
			local title_col = title_start - 1
			local pane_col = title_col - math.floor((ghosty_width - ghosty_title_width()) / 2)

			return {
				buf = buf,
				start_row = start_row,
				col = centered_art_col(math.max(0, pane_col)),
			}
		end
	end
end

local function render_ghosty_frame()
	if not dashboard_animation_enabled() then
		pause_dashboard_animation()
		return
	end

	if vim.fn.getchar(1) ~= 0 then
		pause_dashboard_animation()
		return
	end

	if vim.fn.mode():sub(1, 1) == "c" then
		return
	end

	local win, buf = find_dashboard()
	if not win or not buf then
		stop_dashboard_animation()
		return
	end

	if not ghosty_art_state or ghosty_art_state.buf ~= buf then
		ghosty_art_state = locate_ghosty_art(buf)
	end
	if not ghosty_art_state then
		return
	end

	local frames = load_ghosty_frames()
	ghosty_frame = ghosty_frame % #frames + 1
	local frame_lines = vim.split(frames[ghosty_frame], "\n", { plain = true })

	vim.api.nvim_buf_clear_namespace(
		buf,
		ghosty_art_ns,
		ghosty_art_state.start_row,
		ghosty_art_state.start_row + ghosty_height
	)
	for row = 1, ghosty_height do
		local buf_row = ghosty_art_state.start_row + row - 1
		local art = frame_lines[row] or ""
		local width = vim.fn.strdisplaywidth(art)
		if width < ghosty_art_width then
			art = art .. string.rep(" ", ghosty_art_width - width)
		end

		vim.api.nvim_buf_set_extmark(buf, ghosty_art_ns, buf_row, 0, {
			virt_text = { { art, "GhostyDashboardArt" } },
			virt_text_pos = "overlay",
			virt_text_win_col = ghosty_art_state.col,
			priority = 20,
		})
	end
end

local function start_dashboard_animation()
	if not dashboard_animation_enabled() then
		return
	end

	local art_state = ghosty_art_state
	stop_dashboard_animation()
	ghosty_art_state = art_state

	render_ghosty_frame()

	ghosty_timer = vim.uv.new_timer()
	ghosty_timer:start(
		50,
		50,
		vim.schedule_wrap(function()
			render_ghosty_frame()
		end)
	)
end

pause_dashboard_animation = function()
	if ghosty_timer then
		ghosty_timer:stop()
		ghosty_timer:close()
		ghosty_timer = nil
	end

	local _, buf = find_dashboard()
	if buf then
		vim.api.nvim_buf_clear_namespace(buf, ghosty_art_ns, 0, -1)
	end
	vim.cmd("redraw!")
end

resume_dashboard_animation = function()
	if ghosty_timer or not dashboard_animation_enabled() then
		return
	end

	local _, buf = find_dashboard()
	if not buf then
		return
	end

	start_dashboard_animation()
end

local function sync_dashboard_animation()
	local _, buf = find_dashboard()
	if not buf then
		return
	end

	vim.api.nvim_buf_clear_namespace(buf, ghosty_art_ns, 0, -1)
	paint_dashboard_background()

	if ghosty_timer then
		render_ghosty_frame()
	else
		resume_dashboard_animation()
	end
end

local function set_dashboard_highlights()
	local header_hl = vim.api.nvim_get_hl(0, { name = "SnacksDashboardHeader" })
	local key_hl = vim.api.nvim_get_hl(0, { name = "SnacksDashboardKey" })

	vim.api.nvim_set_hl(0, "GhostyDashboardArt", {
		fg = header_hl.fg,
		bg = "NONE",
		bold = header_hl.bold,
	})
	vim.api.nvim_set_hl(0, "GhostyDashboardTitle", {
		fg = key_hl.fg or header_hl.fg,
		bg = "NONE",
		bold = true,
	})
end

function M.sections()
	return {
		function()
			return {
				header = ghosty_header(),
				hl = "GhostyDashboardArt",
				align = "center",
				padding = 0,
				render = set_ghosty_art_position,
			}
		end,
		function()
			return {
				header = ghosty_title_header(),
				hl = "GhostyDashboardTitle",
				align = "center",
				padding = ghosty_title_padding,
			}
		end,
		{ pane = 2, title = "  Keymaps", section = "keys", indent = 2, gap = 0, padding = { 1, 0 } },
		{
			pane = 2,
			title = "  Recent Files",
			section = "recent_files",
			indent = 2,
			padding = 1,
			limit = 5,
		},
		{
			pane = 2,
			title = "  Projects",
			section = "projects",
			indent = 2,
			padding = 1,
			limit = 3,
		},
		{ pane = 2, section = "startup", padding = 1 },
	}
end

local function set_dashboard_keymaps(buf)
	for _, key in ipairs({ ":", "/", "?" }) do
		vim.keymap.set("n", key, function()
			pause_dashboard_animation()
			return key
		end, { buffer = buf, expr = true, silent = false })
	end
end

function M.setup()
	local group = vim.api.nvim_create_augroup("GhostyDashboardAnimation", { clear = true })

	set_dashboard_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = set_dashboard_highlights,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "SnacksDashboardOpened",
		callback = function()
			start_dashboard_animation()
			vim.schedule(paint_dashboard_background)
			local _, buf = find_dashboard()
			if buf then
				set_dashboard_keymaps(buf)
			end
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "SnacksDashboardClosed",
		callback = stop_dashboard_animation,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "SnacksDashboardUpdatePost",
		callback = function()
			vim.schedule(sync_dashboard_animation)
		end,
	})
	vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "ColorScheme" }, {
		group = group,
		callback = function()
			ghosty_art_state = nil
			vim.schedule(function()
				sync_dashboard_animation()
			end)
		end,
	})
	vim.api.nvim_create_autocmd("CmdlineEnter", {
		group = group,
		callback = pause_dashboard_animation,
	})
	vim.api.nvim_create_autocmd("CmdlineLeave", {
		group = group,
		callback = function()
			vim.schedule(resume_dashboard_animation)
		end,
	})
	vim.api.nvim_create_user_command("DashboardAnimationToggle", function()
		if vim.g.dashboard_animation == false then
			vim.g.dashboard_animation = true
			start_dashboard_animation()
			vim.notify("Dashboard animation enabled", vim.log.levels.INFO, { title = "Dashboard" })
			return
		end

		vim.g.dashboard_animation = false
		pause_dashboard_animation()
		vim.notify("Dashboard animation disabled", vim.log.levels.INFO, { title = "Dashboard" })
	end, { desc = "Toggle dashboard animation" })
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = stop_dashboard_animation,
	})
end

return M
