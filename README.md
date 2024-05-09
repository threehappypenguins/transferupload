Install prerequisites:
python

Clone the repository and enter it:
```console
git clone git@github.com:threehappypenguins/transferupload.git
cd transferupload
```

Create a file called `.env` and in the file, edit the values according to your needs:
```console
HOME_PATH=/home/user
```

Create systemd service file called `transferupload.service` and change `ExecStart` to your user's home path, changing `user` accordingly.
```console
[Unit]
Description=Email notify when MP4 is finished transferring, then upload to YouTube and Sermon Audio. Email notify when Sermon Audio is finished encoding, then publish. Add metadata tags to MP4 and rename for archiving.

[Service]
ExecStart=/home/user/transferupload/run.sh

[Install]
WantedBy=multi-user.target
```

Make install script executable, then run the script as sudo user:
```console
chmod +x install.sh
sudo ./install.sh
```

To verify that the service is running:
```console
systemctl status transferupload
# press ctrl+c to close
```

To uninstall:
```console
sudo ./uninstall.sh
```