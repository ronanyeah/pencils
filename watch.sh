#!/bin/bash
chokidar '**/*.elm' -c 'elm-make --debug --warn Main.elm --output index.html' --initial
