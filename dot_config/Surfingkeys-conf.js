// Portable Surfingkeys overrides for Chromium-based browsers.
// Import this file from Surfingkeys' Advanced settings.

// Keep browser navigation and tab movement consistent with Vim/Tridactyl.
api.map("H", "S");
api.map("L", "D");
api.map("J", "R");
api.map("K", "E");
api.map("gt", "T");

settings.hintAlign = "left";
settings.hintCharacters = "asdfgqwertzxcvb";
settings.omnibarMaxResults = 20;
settings.focusFirstCandidate = true;

settings.theme = `
.sk_theme {
  font-family: "Maple Mono NF CN", "Noto Sans CJK SC", sans-serif;
  font-size: 11pt;
  background: #1b1e37;
  color: #e1e1e2;
}
.sk_theme tbody {
  color: #e1e1e2;
}
.sk_theme input {
  color: #ffffff;
}
.sk_theme .url {
  color: #7aa2f7;
}
.sk_theme .annotation {
  color: #7dcfff;
}
.sk_theme .omnibar_highlight {
  color: #e2c779;
}
.sk_theme .omnibar_timestamp {
  color: #bb9af7;
}
.sk_theme .omnibar_visitcount {
  color: #9ece6a;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
  background: #24283b;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
  background: #414868;
}
#sk_status, #sk_find {
  font-size: 14pt;
}
`;
