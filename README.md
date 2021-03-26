# HPC IGV

Singularity container for custom [IGV webapp](https://igv.org). Intended for HPC/server use where server-local files need to be accessed.

## Building container

In machine with `sudo singularity` access:

```bash
sudo singularity build hpcigv.sif hpcigv.def
```

Then copy *hpcigv.sif* to your server.

## Running container

Server side:

```bash
PORT=31337 # Some unused port in server
singularity exec --bind $HOME/hpcigv/custom:/igv-webapp/dist/custom --bind $HOME/data:/igv-webapp/dist/data hpcigv.sif npx http-server --port $PORT /igv-webapp/dist
```

File $HOME/hpcigv/custom/igv/igv.json defines custom samples. Samples are binded to appropriate directory within container and igv-webapp. Here, hg38 genome must be selected to see server-side samples. If other genomes are needed edit trackRegistry.json and rebuild container.


## Connecting IGV

From workstation:

```bash
ssh -N -L 8999:<serveraddress>:"${PORT}" <serveruser>@<serveraddress>
# Then open browser in address localhost:8999
```

Select hg38 genome to see DemoProject in Tracks- menu.

## Tips

Use separate server-side igv.jsons for different projects. Bind singularity mounts accordingly.

## TODO

- Server side shell script for building igv.json automatically
- Use smaller base image
