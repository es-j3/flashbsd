## FlashBSD
> Just a GUI dd frontend
> I noticed the absence of GUI USB Flashing tools on the BSD's in general, so might as well fix that :)

YAD and BASH are required: 

```pkg install yad bash```

```pkg_add yad bash```

```pkgin install yad bash```

```fetch https://raw.githubusercontent.com/es-j3/flashbsd/main/flashbsd.sh```

```chmod +x flashbsd.sh```

```bash flashbsd.sh```
