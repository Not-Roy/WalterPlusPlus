MOD_NAME="WalterPlusPlus_dev"

DST_MODS_FOLDER="C:/Program Files (x86)/Steam/steamapps/common/Don't Starve Together/mods"
MOD_FOLDER="$DST_MODS_FOLDER/$MOD_NAME"

echo "Mod folder: $MOD_FOLDER"

if [ ! -d "$MOD_FOLDER" ]; then
	echo "Mod folder not found, creating mod folder"
	mkdir "$MOD_FOLDER"
fi

echo "Copying files into mod folder"
cp -r ./* "$MOD_FOLDER"