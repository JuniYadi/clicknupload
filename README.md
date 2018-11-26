## clicknupload.sh
### bash script for downloading clicknupload files

##### Download single file from clicknupload

```bash
./clicknupload.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one clicknupload.org url per line)

```bash
./clicknupload.sh url-list.txt
```

##### Example:

```bash
./clicknupload.sh https://clicknupload.org/qpyyzck09p0p
```

clicknupload.sh uses `wget` with the `-C` flag, which skips over completed files and attempts to resume partially downloaded files.

### Requirements: `coreutils`, `grep`, `sed`, **`wget`**
