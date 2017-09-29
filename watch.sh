#!/bin/bash
chokidar '**/*.elm' -c 'elm make Main.elm --output index.html' --initial
