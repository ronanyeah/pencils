#!/bin/bash
chokidar '**/*.elm' -c 'elm-make --debug --warn Main.elm --output ./public/index.html' --initial
