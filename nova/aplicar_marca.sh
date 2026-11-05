#!/usr/bin/env bash
# Aplica la marca Nova Ingeniería sobre el árbol de RustDesk (con submódulos ya bajados).
# Lo corre el workflow nova-windows.yml justo después del checkout. Falla si algún reemplazo
# no encuentra exactamente lo que espera: así una versión nueva de RustDesk no compila un
# cliente a medio marcar.
set -euo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RAIZ"

APP_NAME="NovaRemoto"
SERVIDOR="remoto.novatechnology-support.com.ar"
# Llave pública del hbbs de Nova (BAREMETAL /root/rustdesk/data/id_ed25519.pub).
LLAVE="ZStbb6QWLFXZPoCU4oY5DYUXhV1E8Wmgeqqb51CeszE="
SOPORTE="https://soporte.novatechnology-support.com.ar"
# Código fuente del cliente modificado (AGPL-3.0).
FUENTE="https://github.com/jlcastillolp-pixel/nova-remoto"

reemplazar() { # archivo  literal_viejo  literal_nuevo   (admite varias líneas; el archivo queda en LF)
  python3 - "$1" "$2" "$3" <<'PY'
import sys
f, viejo, nuevo = sys.argv[1:4]
t = open(f, encoding="utf-8").read()
n = t.count(viejo)
if n != 1:
    sys.exit(f"ERROR: en {f} se esperaba 1 vez «{viejo}» y hay {n}")
t = t.replace(viejo, nuevo, 1)
open(f, "w", encoding="utf-8", newline="").write(t)
if nuevo not in open(f, encoding="utf-8").read():
    sys.exit(f"ERROR: no quedó «{nuevo}» en {f}")
PY
}

CFG=libs/hbb_common/src/config.rs
reemplazar "$CFG" 'pub const RENDEZVOUS_SERVERS: &[&str] = &["rs-ny.rustdesk.com"];' \
  "pub const RENDEZVOUS_SERVERS: &[&str] = &[\"$SERVIDOR\"];"
reemplazar "$CFG" 'pub const RS_PUB_KEY: &str = "OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw=";' \
  "pub const RS_PUB_KEY: &str = \"$LLAVE\";"
reemplazar "$CFG" 'pub static ref APP_NAME: RwLock<String> = RwLock::new("RustDesk".to_owned());' \
  "pub static ref APP_NAME: RwLock<String> = RwLock::new(\"$APP_NAME\".to_owned());"

RC=flutter/windows/runner/Runner.rc
reemplazar "$RC" '"CompanyName", "Purslane Tech Pte. Ltd."' '"CompanyName", "Nova Ingenieria"'
reemplazar "$RC" '"FileDescription", "RustDesk Remote Desktop"' '"FileDescription", "Nova Remoto - Soporte remoto de Nova Ingenieria"'
reemplazar "$RC" '"ProductName", "RustDesk"' "\"ProductName\", \"$APP_NAME\""
reemplazar "$RC" '"LegalCopyright", "Copyright © 2026 Purslane Tech Pte. Ltd. All rights reserved."' \
  '"LegalCopyright", "Nova Ingenieria. Basado en RustDesk (AGPL-3.0, Purslane Tech Pte. Ltd.)"'

# El exe portable es el empaquetador libs/portable: sus datos de versión salen de su Cargo.toml.
PT=libs/portable/Cargo.toml
reemplazar "$PT" 'LegalCopyright = "Copyright © 2026 Purslane Tech Pte. Ltd. All rights reserved."' \
  'LegalCopyright = "Nova Ingenieria. Basado en RustDesk (AGPL-3.0, Purslane Tech Pte. Ltd.)"'
reemplazar "$PT" 'ProductName = "RustDesk"' "ProductName = \"$APP_NAME\""
reemplazar "$PT" 'OriginalFilename = "rustdesk.exe"' "OriginalFilename = \"$APP_NAME.exe\""
reemplazar "$PT" 'FileDescription = "RustDesk Remote Desktop"' 'FileDescription = "Nova Remoto - Soporte remoto de Nova Ingenieria"'
reemplazar "$PT" '#ProductVersion = ""' 'CompanyName = "Nova Ingenieria"'

# Enlaces de «Programas instalados» del MSI.
MSI=res/msi/preprocess.py
reemplazar "$MSI" $'"msi": "ARPCONTACT",\n        "v": "https://github.com/rustdesk/rustdesk",' \
  "\"msi\": \"ARPCONTACT\",
        \"v\": \"$SOPORTE\","
reemplazar "$MSI" $'"msi": "ARPHELPLINK",\n        "v": "https://github.com/rustdesk/rustdesk/issues/",' \
  "\"msi\": \"ARPHELPLINK\",
        \"v\": \"$SOPORTE\","
reemplazar "$MSI" $'"msi": "ARPREADME",\n        "v": "https://github.com/rustdesk/rustdesk",' \
  "\"msi\": \"ARPREADME\",
        \"v\": \"$FUENTE\","

M=nova/marca
cp -f "$M/icon.ico" res/icon.ico
cp -f "$M/tray-icon.ico" res/tray-icon.ico
cp -f "$M/icon.png" res/icon.png
cp -f "$M/32x32.png" res/32x32.png
cp -f "$M/64x64.png" res/64x64.png
cp -f "$M/128x128.png" res/128x128.png
cp -f "$M/128x128@2x.png" res/128x128@2x.png
cp -f "$M/mac-icon.png" res/mac-icon.png
cp -f "$M/app_icon.ico" flutter/windows/runner/resources/app_icon.ico
# La UI de Flutter prefiere assets/icon.png sobre icon.svg y muestra logo_{light,dark}.png arriba.
cp -f "$M/icon.png" flutter/assets/icon.png
cp -f "$M/logo.png" flutter/assets/logo.png
cp -f "$M/logo_light.png" flutter/assets/logo_light.png
cp -f "$M/logo_dark.png" flutter/assets/logo_dark.png

echo "Marca Nova aplicada: APP_NAME=$APP_NAME servidor=$SERVIDOR llave=$LLAVE"
grep -nE 'RENDEZVOUS_SERVERS: |RS_PUB_KEY: |APP_NAME: RwLock' "$CFG"
