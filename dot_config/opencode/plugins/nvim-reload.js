import { readdirSync } from "node:fs";
import { join } from "node:path";

// Ask every running Neovim instance to notice files edited by OpenCode.
// Neovim keeps modified buffers untouched; :checktime only reloads buffers
// that are safe to refresh.
export const NvimReloadPlugin = async ({ $ }) => {
  const uid = process.getuid?.();
  const runtimeDir = process.env.XDG_RUNTIME_DIR ?? (uid === undefined ? undefined : `/run/user/${uid}`);
  const sockets = new Set();
  let pending;

  function refreshSockets() {
    if (!runtimeDir) return;
    try {
      for (const entry of readdirSync(runtimeDir, { withFileTypes: true })) {
        if (entry.name.startsWith("nvim.") && entry.isSocket()) {
          sockets.add(join(runtimeDir, entry.name));
        }
      }
    } catch {
      // No runtime directory or no permission means there is nothing to reload.
    }
  }

  async function reload(socket) {
    try {
      await $`nvim --server ${socket} --remote-send ${"<Esc>:checktime<CR>"}`.quiet();
      return true;
    } catch {
      return false;
    }
  }

  async function broadcast() {
    refreshSockets();
    const active = [...sockets];
    const results = await Promise.allSettled(active.map(reload));
    results.forEach((result, index) => {
      if (result.status === "fulfilled" && !result.value) sockets.delete(active[index]);
    });
  }

  refreshSockets();
  return {
    event: async ({ event }) => {
      if (event.type === "file.watcher.updated") {
        refreshSockets();
        return;
      }
      if (event.type !== "file.edited") return;
      if (pending) clearTimeout(pending);
      pending = setTimeout(() => {
        pending = undefined;
        void broadcast();
      }, 120);
    },
  };
};
