# Steam Artwork Tools

A collection of shell scripts to automate the process of setting up Steam library artwork.

Each Steam app has the following media files: capsule, header, hero, icon, logo.

To set up the artwork for a game, the following steps are required:

1. Copy the template `0` directory and rename it to the game's Steam ID.
1. Download the media files from the internet. [SteamGridDB](https://www.steamgriddb.com/) is a good source of all the artwork files. You can have multiple files for each type of media.
1. Run the `create-symlinks.sh` script to create symbolic links to the media files. It will create a symlink for each media file in the game's directory. If there are multiple files for a media type, the script will create a symlink to the random one.
1. Run the `set-assets.sh` script to set the artwork for the game. It will copy the media files from the corresponding assets directory to the Steam directories.
1. Manually adjust the position of the logo in the Steam client and run the `save-logo-position.sh` script to save the position in the `assets` directory.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
