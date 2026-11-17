#!/usr/bin/env bash
# Corrige o quadrado preto e o logo do Windows descentralizado. Rode: sudo ./fix-boot.sh
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Rode com sudo: sudo ./fix-boot.sh"; exit 1; }
DIR="$(cd "$(dirname "$0")" && pwd)"

# 1) Tema: terminal em tela cheia
cp "$DIR/NeonBraid/theme.txt" /boot/grub/themes/NeonBraid/theme.txt

# 2) Entrada do Windows que volta ao modo de vídeo do firmware antes de iniciar
cat > /etc/grub.d/06_00_windows <<'ENTRY'
#!/bin/sh
exec tail -n +3 $0
menuentry "Win11 (on /dev/nvme0n1p3)" --class windows --class os --id osprober-efi-BC87-23C8 {
	insmod part_gpt
	insmod fat
	search --no-floppy --fs-uuid --set=root BC87-23C8
	chainloader /efi/Microsoft/Boot/bootmgfw.efi
	terminal_output console
}
ENTRY
chmod +x /etc/grub.d/06_00_windows

# 3) Esconde a entrada antiga do Windows gerada pelo os-prober (evita duplicada)
P=/etc/grub.d/07_os-prober_proxy
B="/root/07_os-prober_proxy.bak.$(date +%Y%m%d%H%M%S)"; cp "$P" "$B"; chmod -x "$B"
sed -i "s|^+'Windows Boot Manager (on /dev/nvme0n1p3)'~3fdab34be2e703908a1cca94623e1aa4~ as 'Win11 (on /dev/nvme0n1p3)'|-'Windows Boot Manager (on /dev/nvme0n1p3)'~3fdab34be2e703908a1cca94623e1aa4~|" "$P"

update-grub
echo; echo "Entradas no menu:"; grep -E '^(menuentry|submenu)' /boot/grub/grub.cfg | cut -d'"' -f2
