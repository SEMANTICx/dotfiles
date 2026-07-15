#!/bin/bash

set -euo pipefail

emit_candidates() {
	local session project repo worktree branch symbols
	local -a projects=("$PWD")
	local -a repos=()
	local -A seen_projects=()
	local -A seen_repos=()

	while IFS= read -r session; do
		[[ "$session" == _popup_* ]] && continue
		printf 'session\t%s\t▼  %s\n' "$session" "$session"
		tmux list-windows -t "=$session" -F $'window\t#{session_name}:#{window_index}\t   ⦿  #{window_index}:#{window_name}'
	done < <(tmux list-sessions -F '#{session_name}')

	if command -v zoxide >/dev/null 2>&1; then
		while IFS= read -r project; do
			[[ -d "$project" ]] || continue
			projects+=("$project")
		done < <(zoxide query --list)
	fi

	for project in "${projects[@]}"; do
		[[ -d "$project" ]] || continue
		if [[ -z "${seen_projects[$project]:-}" ]]; then
			seen_projects[$project]=1
			printf 'project\t%s\t◆  %s\n' "$project" "$project"
		fi

		command -v wt >/dev/null 2>&1 || continue
		command -v jq >/dev/null 2>&1 || continue
		repo="$(git -C "$project" rev-parse --show-toplevel 2>/dev/null)" || continue
		[[ -z "${seen_repos[$repo]:-}" ]] || continue
		seen_repos[$repo]=1
		repos+=("$repo")
	done

	# Query independent repositories concurrently so a large zoxide database
	# does not make opening the popup feel sluggish.
	while IFS=$'\t' read -r branch worktree symbols; do
		[[ -n "$worktree" && -d "$worktree" ]] || continue
		printf 'worktree\t%s\t◇  %s %-4s %s\n' "$worktree" "$branch" "$symbols" "$worktree"
	done < <(
		printf '%s\0' "${repos[@]}" |
			xargs -0 -r -n 1 -P 8 bash -c '
				wt -C "$1" list --format json 2>/dev/null |
					jq -r '\''.[] | [.branch // "(detached)", .path, .symbols // ""] | @tsv'\''
			' _
	)
}

selection="$(
	emit_candidates | fzf \
		--reverse \
		--no-border \
		--delimiter=$'\t' \
		--with-nth=3.. \
		--prompt='session/project/worktree> '
)" || exit 0

IFS=$'\t' read -r kind target _ <<< "$selection"
[[ -n "${target:-}" ]] || exit 0

case "$kind" in
	session | window)
		tmux switch-client -t "$target"
		;;
	project | worktree)
		session_name="${target%/}"
		session_name="${session_name##*/}"
		session_name="$(printf '%s' "$session_name" | tr '.:' '__' | tr -cs '[:alnum:]_-' '_')"
		[[ -n "$session_name" ]] || session_name="project"

		if ! tmux has-session -t "=$session_name" 2>/dev/null; then
			tmux new-session -d -s "$session_name" -c "$target"
		fi
		tmux switch-client -t "=$session_name"
		;;
esac
