#!/bin/sh
set -eu

if [ -d "${HOME}/.config/aria2" ]; then
  chmod 0700 "${HOME}/.config/aria2"
fi
if [ -f "${HOME}/.config/aria2/aria2.conf" ]; then
  chmod 0600 "${HOME}/.config/aria2/aria2.conf"
fi
if [ -d "${HOME}/.aria2" ]; then
  chmod 0700 "${HOME}/.aria2"
fi
