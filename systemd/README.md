# Systemd unit and config files

Edit `hpcigv.conf` according to needs. 

```
$ cp hpcigv.service ~/.config/systemctl/user/
$ cp hpcigv.conf ~/.config/systemctl/
$ systemctl --user daemon-reload
$ systemctl --user start hpcigv
$ systemctl --user enable hpcigv
```
