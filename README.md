<h1>Transfer Upload</h1>

I needed a way to automate uploading my church's sermons right after they were finished recording, with minimal effort on Sunday so I could make better use of the day. Sometime before Sunday, when I find out the title and all necessary metadata, I add the metadata to some .json files. Then on Sunday, the recording is sent to the server, and the scripts take care of everything.

This is a series of bash scripts that will do the following:
1. Detect a complete MP4 transfer
2. Email that the transfer was completed (or interrupted)
3. Upload the video to YouTube and Sermon Audio simultaneously
4. Wait for video to be finished processing on Sermon Audio, then publish and post to Facebook and Twitter (if they are connected via Sermon Audio)
5. Add MP4 metadata
6. Rename for archiving

For an easy way of creating the metadata files:
* `am-yt-data.json`
* `am-sa-data.json`
* `am-data.json`
* `pm-yt-data.json`
* `pm-sa-data.json`
* `pm-data.json`

I highly suggest using [Jobson](https://github.com/adamkewley/jobson). See `sample.sh` and `spec.yml` in the `jobson` folder for setup suggestions and a script.

<h2>Installation</h2>

Before you begin, if you want the emailing feature to work, you will need to set up your system to handle outgoing mail. [These are instructions](https://apiit.atlassian.net/wiki/spaces/ITSM/pages/1205567492/How+to+configure+postfix+relay+to+Office365+on+Ubuntu) for setting it up with Office365.

1. Install prerequisites:
```console
sudo apt install inotify-tools python-is-python3 atomicparsley exiftool
```

2. Install MP4Box build following [these instructions](https://github.com/gpac/gpac/wiki/GPAC-Build-Guide-for-Linux#mp4box--gpac-only-minimal-static-build).

Then copy the MP4Box binary to `/usr/local/bin`:
```console
sudo cp ~/gpac_public/bin/gcc/MP4Box /usr/local/bin/MP4Box
```

3. Install [YouTube Uploader](https://github.com/porjo/youtubeuploader).

4. Obtain your Sermon Audio [API Key](https://www.sermonaudio.com/new_details.asp?ID=26017).

5. Make sure you begin in your user's home directory. If you're not sure, log in as your user (not root) and:
```console
cd
```

Clone the repository and enter it:
```console
git clone git@github.com:threehappypenguins/transferupload.git
cd transferupload
```

6. Create a file called `.env` and in the file, edit the values according to your needs (use the `sample.env` file as a template).

7. Create systemd service file called `transferupload.service` and change `ExecStart` to your user's home path, changing `user` accordingly.
```console
[Unit]
Description=Email notify when MP4 is finished transferring, then upload to YouTube and Sermon Audio. Email notify when Sermon Audio is finished encoding, then publish. Add metadata tags to MP4 and rename for archiving.

[Service]
ExecStart=/home/user/transferupload/src/run.sh

[Install]
WantedBy=multi-user.target
```

Make install script executable, then run the script as sudo user:
```console
chmod +x install.sh
sudo ./install.sh
```

8. To verify that the service is running:
```console
systemctl status transferupload
# press ctrl+c to close
```

9. To uninstall:
```console
sudo ./uninstall.sh
```

<h2>Other Info</h2>

If you get the error `—include or —includei is an unrecognized option`, you need to install a build of inotify-tools:
```console
sudo apt remove inotify-tools
cd
git clone https://github.com/inotify-tools/inotify-tools.git inotify-tools
cd inotify-tools
```
And follow [these directions](https://github.com/inotify-tools/inotify-tools/blob/master/INSTALL).