# Nova Remoto

Cliente de soporte remoto de **Nova Ingeniería**, derivado de [RustDesk](https://github.com/rustdesk/rustdesk)
1.5.1 (AGPL-3.0). Este repositorio publica el código fuente del cliente modificado, como pide la licencia.

## Qué cambia respecto de RustDesk

Nada del código de RustDesk se edita en la rama: la marca se aplica en el build con `nova/aplicar_marca.sh`.

- Nombre de la aplicación: `NovaRemoto`.
- Servidor de ID y relay propio: `remoto.novatechnology-support.com.ar` (puertos 21115–21117), con su llave pública.
- Íconos y logos de Nova (`nova/marca/`).
- Datos de la versión del ejecutable (empresa, descripción, producto).

Si una versión nueva de RustDesk cambia alguna de las líneas que el script reemplaza, el script falla y el
build se corta: no se publica un cliente a medio marcar.

## Cómo se compila

Actions → **Nova Remoto - cliente Windows x64** → *Run workflow*. Deja `NovaRemoto-<versión>-x64.exe`
(portable, se ejecuta sin instalar y desde ahí se puede instalar) y `NovaRemoto-<versión>-x64.msi` en un release.

## Actualizar a una versión nueva de RustDesk

1. Crear la rama `nova-<versión>` desde la etiqueta `<versión>` de rustdesk/rustdesk.
2. Copiar `nova/`, `NOVA.md` y `.github/workflows/nova-windows.yml`.
3. Comparar `nova-windows.yml` con el job `build-for-windows-flutter` del `flutter-build.yml` nuevo
   (versiones de Flutter, vcpkg y Rust) y actualizar `VERSION`.
4. Correr el workflow: si `aplicar_marca.sh` falla, ajustar el literal que cambió.
