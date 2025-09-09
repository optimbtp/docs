#!/bin/bash
# Script to run MkDocs with virtual environment

cd /home/azer/docs-optimbtp
source .venv/bin/activate
mkdocs serve --dev-addr=127.0.0.1:8001
