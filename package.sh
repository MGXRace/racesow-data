#!/bin/bash
INVENTORY=(
    gfx
    huds
    models
    progs
    fonts
    scripts
    ui
    default.cfg
    playervisibilityfull.cfg
    playervisibilitynormal.cfg
    playervisibilityoff.cfg
    rs_defaults.cfg
)

rm -rf ui/.cache
zip -r data_$(date +%Y%m%d)_pure.pk3 ${INVENTORY[@]}
