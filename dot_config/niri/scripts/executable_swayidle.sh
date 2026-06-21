#!/usr/bin/env bash

# 5分钟锁屏，10分钟熄屏，20分钟睡眠
# swaylock -f是前台运行swaylock，如果不加的话后续的timeout命令会不生效

swayidle -w \
    timeout 300  'swaylock -f' \
    timeout 600  'niri msg action power-off-monitors' \
    resume       'niri msg action power-on-monitors' \
    timeout 1200 'systemctl suspend' \
