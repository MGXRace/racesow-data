#!/bin/bash
which zip >/dev/null 2>&1
if [ $? -ne 0 ]; then
  if [ ! -z "$SEVENZIP" ]; then
    if [ ! -f "$SEVENZIP" ]; then
      echo "Could not find 7-zip executable at $SEVENZIP"
      exit
    fi
  else
    echo -e "No zip utility found. For the Git Bash shell in Windows, 7-zip can be used by specifying its path, for example:\nexport SEVENZIP=\"C:/Program Files/7-Zip/7z.exe\""
    exit
  fi
fi
INVENTORY=(
    gfx
    huds
    models
    progs
    fonts
    scripts
    sounds
    ui
    default.cfg
    playervisibilityfull.cfg
    playervisibilitynormal.cfg
    playervisibilityoff.cfg
    rs_defaults.cfg
)

[ -f .revision ] || echo "0" > .revision
revision=000$(( 10#$(cat .revision) + 1 ))
revision=${revision:(-3)}
echo $revision > .revision
rm -rf ui/.cache
package=data_$(date +%Y%m%d)-${revision}.pk3
if [ ! -z "$SEVENZIP" ]; then
  "$SEVENZIP" a -tzip ${package} ${INVENTORY[@]} >/dev/null 2>&1 && echo "Succesfully created package $package"
else
  zip -r ${package} ${INVENTORY[@]} && echo "Succesfully created package $package"
fi
