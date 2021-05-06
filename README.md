# HPC IGV

Singularity container for custom [IGV webapp](https://igv.org). Intended for HPC/server use where server-local files need to be accessed.

## Installation

### Buiding container

Usually container building is not possible inside cluster. In machine with `sudo singularity` access:

```bash
sudo singularity build hpcigv.sif hpcigv.def
```

Then copy *hpcigv.sif* to your cluster.


### On HPC cluster

- `git clone https://github.com/thakk/hpcigv`
- Edit *hpcigv/launcher.sh*. Modify variables CONTAINER and BINDPATHS to suit your cluster.


### On Windows workstation


- `git clone https://github.com/thakk/hpcigv`
- Install [Cygwin](https://www.cygwin.com/) with ssh client. Configure ssh keys and enable non-interactive logging to your cluster.
- Edit *hpcigv/hpcigv_cygwinlauncher.sh* . Modify variable IGVLAUNCHER to match your cluster installation.
- (optional) Create desktop icon for IGV. For example copy Cygwin launcher icon and modify Properties->Shortcut->Target to something like `D:\cygwin64\bin\mintty.exe /bin/env /bin/bash --login /cygdrive/c/Users/WindowsUser/Desktop/bash/hpcigv_cygwinlauncher.sh -u myusername -s myclusterlogin.site.com -g /lustre/compbio/pub/apps/hpcigv-1.0/genomes.json`

### On Linux/Mac/Bsd/... workstation

- `git clone https://github.com/thakk/hpcigv`
- Edit *hpcigv/hpcigv_cygwinlauncher.sh* . Modify variable IGVLAUNCHER to match your cluster installation. Replace 2 last lines so that web browser is opened automatically.

## Launcing IGV

Easiest way to launch IGV on server is to use provided *hpcigv_cygwinlauncher.sh* . This script opens connection to server with ssh and starts IGV container within screen- session. Subsequently ssh tunnel is created and local default browser is opened.


## Server side global configuration

By default *launcher.sh* loads IGV json files under *custom/igv/* . These files define server- side files that are accessible from IGV. To generate json files use *biosamplestojson.sh* . If you wish to use server- side reference files edit *genomes.json*.


## Individual project configuration

Edit *custom/igv/igv.json* and add your files in tracks- section.

## Manually running container

Server side:

```bash
PORT=31337 # Some unused port in server
singularity exec --bind $HOME/hpcigv/custom:/igv-webapp/dist/custom --bind $HOME/data:/igv-webapp/dist/data hpcigv.sif npx http-server --port $PORT /igv-webapp/dist
```

File *hpcigv/custom/igv/igv.json* defines custom samples. Samples must be bound to appropriate directory within container and igv-webapp.


## Connecting IGV

From workstation:

```bash
ssh -N -L 8999:<serveraddress>:"${PORT}" <serveruser>@<serveraddress>
# Then open browser in address localhost:8999
```

Select hg38 genome to see DemoProject in Tracks- menu.

## Tips



## TODO

- Use smaller base image
