function sysup --description 'Update Arch packages and refresh package manifests'
    if not type -q paru
        printf 'sysup: paru is not installed\n' >&2
        return 127
    end

    command paru -Syu $argv
    set -l update_status $status
    if test $update_status -eq 0; and type -q backup-package-lists
        command backup-package-lists
    end
    return $update_status
end
