# Desenvolvimento

Tela 480×270, 60 fps, Lua. O cartucho é um zip chamado `caio-pernocas.lupi`.

## Montar

Precisa de Lua 5.5, `zip` e do submódulo `lupi-codec`. O codec chama `magick` para ler os PNG.

```sh
git submodule update --init
make lupi
lupinho caio-pernocas.lupi
```

| Alvo | Resultado |
| --- | --- |
| `make lupi` | `caio-pernocas.lupi` |
| `make web` | jogo web em `.build/webgame/`, via `hldtux/lupinho-sdk` |
| `make game/codec` | pasta aberta em `dist/current` |
| `make clean` | apaga `caio-pernocas.lupi`, `dist/` e `.build/` |

`make game/codec` copia `.lua`, `.png`, `.json` e `.fur` para `.build/src` e roda `lupi-codec`. Os `.fur` são recolocados no release se o codec não os mantiver.

Arquivos maiores que 16 KB entram no zip sem compressão. O lupinho infla com um buffer de 16 KB e falha quando o arquivo descompactado não cabe nele de uma vez. O mapa `maps/stages/snowy_ov2` tem 25600 bytes.

Cada push na `main` publica o cartucho em [caio-pernocas.lupi](https://github.com/lupi-org-br/caio-pernocas/releases/latest/download/caio-pernocas.lupi) (`.github/workflows/release.yml`) e a versão web em [lupi-org-br.github.io/caio-pernocas](https://lupi-org-br.github.io/caio-pernocas/) (`.github/workflows/pages.yml`).

`make web` monta o `.lupi` e pede ao container `hldtux/lupinho-sdk` o `make web-game`, que embute o cartucho no Lupinho em WebAssembly. A pasta `.build/webgame` recebe `media/web/fullscreen.css` ligado no `game.html`.

No Ubuntu o ImageMagick 6 não tem o comando `magick`; os workflows instalam um atalho para `identify` e `convert`. O Pages do repositório precisa estar em GitHub Actions.

## Áudio

Trilhas em `music.loop`. Os arquivos ficam em `music/` e entram no cartucho como `music/*.fur`, sem extensão na chamada.

| Chamada | Quando |
| --- | --- |
| `music.loop("music/menu")` | Overworld |
| `music.loop("music/w1")` | Fases `w1` |
| `music.loop("music/w2")` | Fases `w2` |

## Arquivos

- `game.lua` — jogo
- `maps/` — mapas Tiled
- `player/`, `poi/`, `tilemap/`, `font/`, `win/` — sprites
- `music/` — trilhas `.fur`
- `lupi-codec/` — converte o estágio em cartucho
