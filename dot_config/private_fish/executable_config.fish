fish_add_path --move ~/.local/bin

# Remove duplicates inherited from parent processes while preserving order.
set -l deduplicated_path
for directory in $PATH
    contains -- $directory $deduplicated_path; or set -a deduplicated_path $directory
end
set -gx PATH $deduplicated_path

if status is-interactive
    set fish_greeting ""
    set -gx STARSHIP_CONFIG ~/.config/starship.toml
    starship init fish | source
    zoxide init fish --cmd cd | source

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function cat
        command bat $argv
    end

    function ls
        command eza --icons $argv
    end

    function lt
        command eza --icons --tree $argv
    end

    # grub
    abbr grub 'LANGUAGE=en_US.UTF-8 LANG=en_US.UTF-8 sudo grub-mkconfig -o /boot/grub/grub.cfg'
    # 小黄鸭补帧 需要steam安装正版小黄鸭
    abbr lsfg 'LSFG_PROCESS="miyu"'
    # fa运行fastfetch
    abbr fa fastfetch
    abbr reboot 'systemctl reboot'

    function sl
        command sl | lolcat
    end

    function 滚
        sysup
    end

    function raw
        command ~/.local/bin/random-anime-wallpaper-dms $argv
    end

    function 安装
        command paru -S $argv
    end

    function 卸载
        command paru -Rns $argv
    end
end
