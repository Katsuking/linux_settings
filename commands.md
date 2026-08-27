### SSDのクリーンアップ LINUX用

```sh
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
lsblk -f
```

/dev/sdX のディスクをまっさらにして、ext4にフォーマットする (パーティション一つ) にする場合

```sh
sudo wipefs -a /dev/sdX # SSDをまっさらに
sudo parted /dev/sdX--script mklabel gpt # GPTを作る
sudo parted /dev/sdX--script mkpart primary ext4 0% 100% # SSD全体にパーティションを作る
sudo mkfs.ext4 /dev/sdX # そのパーティションをext4でフォーマット
```

### SSDをマウント

```sh
$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0         7:0    0     2G  0 loop 
sda           8:0    0 476.9G  0 disk 
└─sda1        8:1    0 476.9G  0 part  <--- こいつをマウントする場合
mmcblk0     179:0    0  58.9G  0 disk 
├─mmcblk0p1 179:1    0   512M  0 part /boot/firmware
└─mmcblk0p2 179:2    0  58.4G  0 part /
zram0       254:0    0     2G  0 disk [SWAP]
```

フォーマットとか確認する場合
[ここ確認](#ssdのクリーンアップ-linux用)

```sh
sudo mkdir -p /mnt/storage # マウント先のディレクトリ作成
sudo mount /dev/sda1 /mnt/storage
```

**再起動時にも自動でマウントされるように /etc/fstab に登録** 必須!!

```sh
sudo blkid /dev/sda1 # UUID確認
```

/etc/fstab に追記

```
UUID=確認したUUID文字列  /mnt/storage  ext4  defaults,noatime  0  2
```

### ssh鍵の作成と転送

```sh
ssh-keygen -t ed25519 -f ~/.ssh/my_server # my_serverという名前の鍵を作成(任意)
ssh-copy-id -p <port number e.g. 22> -i ~/.ssh/my_server.pub <user name e.g. abcuser>@<ipaddress e.g.192.168.1.100> # 鍵の転送 サーバー側が鍵での認証を許可してないとダメ
```

