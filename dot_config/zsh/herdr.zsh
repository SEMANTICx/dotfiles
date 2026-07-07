alias hdr='herdr'
alias hst='herdr status'
alias hrl='herdr server reload-config'
alias hstop='herdr server stop'

hrepo() {
  local root name
  root="$(git rev-parse --show-toplevel 2>/dev/null)"
  [[ -z "$root" ]] && root="$PWD"

  name="${root:t}"
  name="${name//[^A-Za-z0-9_.-]/-}"
  command herdr --session "$name"
}
