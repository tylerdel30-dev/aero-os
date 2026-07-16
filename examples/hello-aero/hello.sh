#!/bin/sh
exec foot sh -c '
echo ""
echo "  ============================================"
echo "   Hello from an .aero app bundle!"
echo ""
echo "   This app was packaged in the Aero OS"
echo "   native format: a manifest.json plus its"
echo "   files, compressed into a single .aero file."
echo "  ============================================"
echo ""
echo "  Press Enter to close."
read dummy
'
