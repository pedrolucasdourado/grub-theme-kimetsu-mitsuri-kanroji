#!/usr/bin/env bash
# Instala o tema NeonBraid no GRUB (Ubuntu). Rode: sudo ./install.sh
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Rode com sudo: sudo ./install.sh"; exit 1; }
SRC="$(cd "$(dirname "$0")" && pwd)/NeonBraid"
DEST=/boot/grub/themes/NeonBraid
CFG=/etc/default/grub

rm -rf "$DEST"; mkdir -p "$DEST"; cp -r "$SRC"/. "$DEST"/
cp "$CFG" "$CFG.bak.$(date +%Y%m%d%H%M%S)"

setkey() { # setkey CHAVE VALOR
  if grep -qE "^#?\s*$1=" "$CFG"; then sed -i -E "s|^#?\s*$1=.*|$1=\"$2\"|" "$CFG"
  else echo "$1=\"$2\"" >> "$CFG"; fi
}
setkey GRUB_THEME "$DEST/theme.txt"
setkey GRUB_GFXMODE "3840x2160,2560x1440,1920x1080,auto"
setkey GRUB_TIMEOUT_STYLE "menu"
sed -i -E 's|^\s*GRUB_TERMINAL(_OUTPUT)?=.*console.*|#&|' "$CFG"

update-grub
echo "Pronto. Tema instalado em $DEST (backup de $CFG criado)."
