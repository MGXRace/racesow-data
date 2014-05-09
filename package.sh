#!/bin/bash
INVENTORY=(
    gfx
    huds
    progs
    ui
    default.cfg
    rs_defaults.cfg
)

rm -rf ui/.cache
zip -r data_$(date +%Y%m%d)_pure.pk3 ${INVENTORY[@]}
