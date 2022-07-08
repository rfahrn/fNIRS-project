#!sh

rm -rf ~/Desktop/Homer2_UI*
rm -rf ~/Desktop/AtlasViewerGUI*

perl ~/Downloads/homer2_install/makefinalapp.pl ~/homer2/run_Homer2_UI.sh ~/Desktop/Homer2_UI.$1
perl ~/Downloads/homer2_install/makefinalapp.pl ~/homer2/run_AtlasViewerGUI.sh ~/Desktop/AtlasViewerGUI.$1

chmod 755 ~/Desktop/Homer2_UI.$1
chmod 755 ~/Desktop/AtlasViewerGUI.$1

exit
