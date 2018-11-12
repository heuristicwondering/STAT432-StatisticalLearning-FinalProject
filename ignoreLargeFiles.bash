#!/bin/bash

find . -size +100M | sed 's|^\./||g' >> .gitignore ; awk '!NF || !seen[$0]++' .gitignore