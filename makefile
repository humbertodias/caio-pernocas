
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
STAGE := $(MAKEFILE_DIR).build/src
CURRENT := $(MAKEFILE_DIR)dist/current
LUPI := $(MAKEFILE_DIR)caio-pernocas.lupi
LIST := $(MAKEFILE_DIR).build/files.list

SDK := hldtux/lupinho-sdk
WEB := $(MAKEFILE_DIR).build/webgame

.PHONY: game/codec lupi web clean

game/codec:
	rm -rf "$(MAKEFILE_DIR)dist" "$(MAKEFILE_DIR).build"
	mkdir -p "$(STAGE)"
	cd "$(MAKEFILE_DIR)" && \
	find . -type f \( -name '*.lua' -o -name '*.png' -o -name '*.json' -o -name '*.fur' \) \
		! -path './.git/*' ! -path './.build/*' ! -path './dist/*' ! -path './lupi-codec/*' \
		> "$(LIST)"
	while IFS= read -r rel; do \
		mkdir -p "$(STAGE)/$$(dirname "$$rel")"; \
		cp "$(MAKEFILE_DIR)$$rel" "$(STAGE)/$$rel"; \
	done < "$(LIST)"
	cd "$(MAKEFILE_DIR)lupi-codec" && lua run.lua "$(STAGE)" "$(MAKEFILE_DIR)dist"

lupi: game/codec
	mkdir -p "$(CURRENT)/music"
	@set -e; \
	manifest="$(CURRENT)/lupi_manifest.txt"; \
	cursor=$$(date +%s)0000; \
	n=0; \
	for src in "$(MAKEFILE_DIR)music/"*.fur; do \
	  name=$$(basename "$$src"); \
	  cp "$$src" "$(CURRENT)/music/$$name"; \
	  if ! grep -q "music/$$name " "$$manifest"; then \
	    size=$$(wc -c < "$(CURRENT)/music/$$name" | tr -d ' '); \
	    printf '%s %s music/%s {"type":"audio"}\n' "$$((cursor + n))" "$$size" "$$name" >> "$$manifest"; \
	    n=$$((n + 1)); \
	  fi; \
	done
	@test -s "$(CURRENT)/game.lua"
	@test -s "$(CURRENT)/palette.lua"
	@test -s "$(CURRENT)/music/menu.fur"
	rm -f "$(LUPI)"
	cd "$(CURRENT)" && zip -r -X "$(LUPI)" .
	cd "$(CURRENT)" && find . -type f -size +16383c -print > "$(MAKEFILE_DIR).build/store.txt"
	@if [ -s "$(MAKEFILE_DIR).build/store.txt" ]; then \
		cd "$(CURRENT)" && zip -0 -X "$(LUPI)" -@ < "$(MAKEFILE_DIR).build/store.txt"; \
	fi
	@echo "Gerado: $(LUPI)"

web: lupi
	rm -rf "$(WEB)"
	mkdir -p "$(WEB)"
	docker run --rm --entrypoint bash \
		-e HOST_UID="$(shell id -u)" \
		-e HOST_GID="$(shell id -g)" \
		-v "$(LUPI):/game.lupi:ro" \
		-v "$(WEB):/out" \
		-v "$(MAKEFILE_DIR)media/web/fullscreen.css:/fullscreen.css:ro" \
		$(SDK) \
		-lc 'set -eo pipefail; source /opt/emsdk/emsdk_env.sh; set -u; make -C /lupinho/lupinho/src web-game GAME_PATH=/game.lupi; cp -a /lupinho/lupinho/dist/webgame/. /out/; cp /fullscreen.css /out/fullscreen.css; sed -i "s|</head>|<link rel=\"stylesheet\" href=\"fullscreen.css\"></head>|" /out/game.html; cp /out/game.html /out/index.html; touch /out/.nojekyll; chown -R "$$HOST_UID:$$HOST_GID" /out'

clean:
	rm -rf dist .build "$(LUPI)"
