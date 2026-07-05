function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%m/%d %H:%M", time)
	else
		time = os.date("%m/%d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

require("full-border"):setup {
	type = ui.Border.ROUNDED,
}

require("git"):setup {
	order = 1500,
}

require("smart-enter"):setup {
	open_multi = true,
}

require("whoosh"):setup {
	bookmarks = {
		{ tag = "Home", path = "~", key = "h" },
		{ tag = "Config", path = "~/.config", key = "c" },
		{ tag = "Documents", path = "~/Documents", key = "d" },
		{ tag = "Downloads", path = "~/Downloads", key = "o" },
		{ tag = "Codex", path = "~/Documents/Codex", key = "w" },
	},
	jump_notify = false,
	path_truncate_enabled = true,
	path_max_depth = 4,
	fzf_path_truncate_enabled = true,
	fzf_path_max_depth = 5,
	history_size = 20,
}
