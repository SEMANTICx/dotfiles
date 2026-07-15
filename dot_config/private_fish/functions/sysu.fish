function sysu --description 'Show active custom systemd user services with listening TCP ports'
    if not type -q systemctl
        printf 'sysu: systemctl is unavailable\n' >&2
        return 127
    end

    set -l config_home (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo $HOME/.config)
    set -l service_directory $config_home/systemd/user
    set -l unit_paths $service_directory/*.service

    if test (count $unit_paths) -eq 0
        printf 'sysu: no custom user services in %s\n' $service_directory
        return 0
    end

    set -l listeners
    if type -q ss
        set listeners (ss -H -ltnp 2>/dev/null)
    end

    for unit_path in $unit_paths
        set -l unit (path basename $unit_path)
        systemctl --user is-enabled --quiet $unit 2>/dev/null; or continue
        systemctl --user is-active --quiet $unit 2>/dev/null; or continue

        set -l control_group (systemctl --user show --property=ControlGroup --value $unit 2>/dev/null)
        set -l process_file /sys/fs/cgroup$control_group/cgroup.procs
        test -r $process_file; or continue
        set -l pids (string split \n -- (string collect < $process_file))
        set -l ports

        for pid in $pids
            for line in (string match -r ".*pid=$pid,.*" -- $listeners)
                set -l port (string replace -r '^.*:([0-9]+)[[:space:]].*$' '$1' -- $line)
                string match -qr '^[0-9]+$' -- $port; and set -a ports $port
            end
        end

        test (count $ports) -gt 0; or continue
        set ports (printf '%s\n' $ports | sort -nu)
        printf '  %-24s' (string replace -r '\.service$' '' -- $unit)
        for port in $ports
            printf ' http://localhost:%s' $port
        end
        printf '\n'
    end
end
