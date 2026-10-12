# GBRetroDev'26 Starter

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A tiny Game Boy game in assembly, built with [GBTelera](https://github.com/lronaldo/gbtelera) (RGBDS + Makefiles). It is the starting point for [#GBRetroDev'26](https://itch.io/jam/gbretrodev26), the Game Boy assembly game jam of the University of Alicante.

*[Leer en español](#gbretrodev26-starter-español)*

## What it does
1. **Menu.** The title and "PRESS START".
2. **Play.** Press START. A ship appears. Move it with the D-pad. It never leaves the walls.
3. **Boom.** Press A. The ship becomes an explosion. One second later, you are back in the menu.

A complete loop (menu → play → result → menu) in under 500 lines of code, graphics and header aside. Change it, break it, make it yours.

## Build and run
You need GBTelera installed, with `GBT_PATH` set. A [class video](https://youtu.be/q552n1F3j9s) (in Spanish) shows how.

```
make                       # builds starter.gb
gbt_bgb starter.gb         # or: gbt_emulicious starter.gb
make clean                 # removes the build files
```

## Files
| File | What is inside |
| --- | --- |
| `src/header.asm` | Cartridge header: type 3 (MBC1+RAM+BATTERY), 32 KiB ROM, 8 KiB SRAM. **The jam requires exactly this.** |
| `src/main.asm` | Entry point and main loop: wait for VBLANK, read input, update the game. |
| `src/game.asm` | The game: 3 states (MENU, PLAY, BOOM), ship movement and limits. |
| `src/input.asm` | Joypad: `input_held` and `input_pressed`. |
| `src/screen.asm` | LCD, VRAM and OAM: everything that touches the screen. |
| `src/gfx.asm`, `src/gfx.inc` | Tiles, font and texts. Tiles are written as pixels (`` `01230123 ``). |
| `cfg/`, `Makefile` | GBTelera build system. |

Each file owns its data. Only `game.asm` writes the ship position and only `input.asm` writes the buttons. The rest call routines or read results.

## Ideas to continue
1. Change the ship and explosion tiles.
2. Add a second sprite that bounces around.
3. Count how many times you press A and show it in the menu.
4. Add sound (the APU registers are in `hardware.inc`).
5. Save the best score in the cartridge SRAM.

## Using it in your #GBRetroDev entry
You are free to use this code. You do not need to cite it, reference it or mention it in your credits if you base your game on it. Of course, if you do, thank you very much :).

Important: keep the cartridge header as it is: type 3, 32 KiB ROM and 8 KiB SRAM.

## Learn more
- Intro class to GBTelera, the tools and a basic project (Spanish): https://youtu.be/q552n1F3j9s
- [Pan Docs](https://gbdev.io/pandocs/): the Game Boy technical reference.
- [RGBDS](https://rgbds.gbdev.io/): the assembler and linker.

## License
[MIT](LICENSE). The `Makefile`, `cfg/` and `src/header.asm` come from the GBTelera template and keep their license notice.

---

# GBRetroDev'26 Starter (español)

*[Read in English](#gbretrodev26-starter)*

Un juego mínimo de Game Boy en ensamblador, hecho con [GBTelera](https://github.com/lronaldo/gbtelera) (RGBDS + Makefiles). Es el punto de partida de la [#GBRetroDev'26](https://itch.io/jam/gbretrodev26), la jam de ensamblador de Game Boy de la Universidad de Alicante.

## Qué hace
1. **Menú.** El título y «PRESS START».
2. **Juego.** Pulsa START. Aparece una nave. Muévela con la cruceta. No sale de los muros.
3. **Boom.** Pulsa A. La nave se convierte en una explosión. Un segundo después, vuelves al menú.

Un bucle completo (menú → juego → resultado → menú) en menos de 500 líneas de código, sin contar gráficos ni cabecera. Cámbialo, rómpelo, hazlo tuyo.

## Compilar y ejecutar
Necesitas GBTelera instalado, con `GBT_PATH` definido. Un [vídeo de clase](https://youtu.be/q552n1F3j9s) (en español) explica cómo.

```
make                       # genera starter.gb
gbt_bgb starter.gb         # o: gbt_emulicious starter.gb
make clean                 # borra los ficheros de compilación
```

## Ficheros
| Fichero | Qué contiene |
| --- | --- |
| `src/header.asm` | Cabecera del cartucho: tipo 3 (MBC1+RAM+BATTERY), 32 KiB de ROM, 8 KiB de SRAM. **La jam exige exactamente esto.** |
| `src/main.asm` | Punto de entrada y bucle principal: esperar al VBLANK, leer la entrada, actualizar el juego. |
| `src/game.asm` | El juego: 3 estados (MENU, PLAY, BOOM), movimiento de la nave y sus límites. |
| `src/input.asm` | El mando: `input_held` e `input_pressed`. |
| `src/screen.asm` | LCD, VRAM y OAM: todo lo que toca la pantalla. |
| `src/gfx.asm`, `src/gfx.inc` | Tiles, fuente y textos. Los tiles se escriben como píxeles (`` `01230123 ``). |
| `cfg/`, `Makefile` | El sistema de compilación de GBTelera. |

Cada fichero es dueño de sus datos. Solo `game.asm` escribe la posición de la nave y solo `input.asm` escribe los botones. El resto llama a rutinas o lee resultados. Los comentarios del código están en inglés.

## Ideas para seguir
1. Cambia los tiles de la nave y de la explosión.
2. Añade un segundo sprite que rebote por la pantalla.
3. Cuenta cuántas veces pulsas A y muéstralo en el menú.
4. Añade sonido (los registros del APU están en `hardware.inc`).
5. Guarda la mejor puntuación en la SRAM del cartucho.

## Usarlo en tu entrega a la #GBRetroDev
Puedes usar este código libremente. No es necesario que lo cites, referencies ni menciones en tus créditos si te basas en él para empezar tu juego. Por supuesto, si lo haces, muchas gracias :).

Importante: mantén la cabecera del cartucho tal como está: tipo 3, 32 KiB de ROM y 8 KiB de SRAM.

## Más información
- Clase de introducción a GBTelera, las herramientas y un proyecto básico (en español): https://youtu.be/q552n1F3j9s
- [Pan Docs](https://gbdev.io/pandocs/): la referencia técnica de Game Boy (en inglés).
- [RGBDS](https://rgbds.gbdev.io/): el ensamblador y enlazador.

## Licencia
[MIT](LICENSE). El `Makefile`, `cfg/` y `src/header.asm` vienen de la plantilla de GBTelera y conservan su aviso de licencia.
