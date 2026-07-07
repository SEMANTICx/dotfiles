if status is-interactive
    abbr -a hdr herdr
    abbr -a hst 'herdr status'
    abbr -a hrl 'herdr server reload-config'
    abbr -a hstop 'herdr server stop'

    function hrepo --description 'Open Herdr session named after the current git repo'
        set -l root (git rev-parse --show-toplevel 2>/dev/null)
        if test -z "$root"
            set root (pwd)
        end

        set -l name (basename "$root" | string replace -ra '[^A-Za-z0-9_.-]' '-')
        command herdr --session "$name"
    end
end
