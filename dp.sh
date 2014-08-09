#!/bin/bash
git add -A .
git commit -m 'auto deploy'
git push
cap deploy