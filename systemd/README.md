# Systemd unit file and option files

`hpcigv.service` is a systemd unit file to run the HPCIGV as a system service. The `hpcigv` contains options for Singularity mounts and HTTP port.

## Example deployment (RHEL)

Edit `hpcigv.conf` according to needs. 

```
$ cp hpcigv.service ~/.config/systemctl/user/
$ cp hpcigv.conf ~/.config/systemctl/
$ systemctl --user daemon-reload
$ systemctl --user start hpcigv
$ systemctl --user enable hpcigv
```
