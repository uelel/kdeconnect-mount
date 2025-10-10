# kdeconnect-mount

Are you having trouble with Pixel (or other Android) phones not being able to mount files via USB?

This bash script mounts the Android filesystem by using the [KDE Connect](https://kdeconnect.kde.org/) utility and some CLI tools.

Tested on Arch Linux.


## 🛠️ Pre-requisites

Before using this script, ensure you have the following installed:  

✅ **KDE Connect** with `kdeconnect-cli` and `qdbus` interface  
✅ **SSHFS** for mounting remote file systems  


## ⚡ Usage

```bash
./kdeconnect-mount.sh (-d <device_id> | -n <device_name>) <mount_path>
```

Example:

```bash
./kdeconnect-mount.sh -n "Pixel 8" /mnt/android
```

To unmount, use:

```bash
fusermount -u <mount_path>
```


## 🚀 Improvement Suggestions

Expand OS Support – Improve compatibility with more Linux distributions and Windows.


## 🗂️ Versioning

| Version | Date         | Changes                                   |
|---------|-------------|-------------------------------------------|
| 1.1.0   | October 2025  | Automatic detection of host and port     |
| 1.0.0   | April 2025  | Initial release                            |


## 📝 License

This project is licensed under the MIT License. Feel free to use, modify, and share!
  
Got ideas or want to contribute? Open an issue or submit a pull request!
  
Happy mounting! 🎉
