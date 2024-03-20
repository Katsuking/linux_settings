### 概要

- [pihole を使用するための設定](./containers/nginx-proxy-manager/README.md)
- [ルーター設定](./router_modem/README.md)

pi-hole や nginx の設定は上記のリンクの内容でできる。

以下は個人的によく使うもののメモ

### ssh の設定

関数にして用意

```sh
sudo adduser "$name" --gecos "" --disabled-password
sudo passwd -d "$name"
sudo mkdir "/home/$name/.ssh"
sudo chown "$name:$name" "/home/$name/.ssh"
sudo chmod 0700 "/home/$name/.ssh"
curl https://github.com/"$github".keys | sudo tee -a "/home/$name/.ssh/authorized_keys"
sudo chown "$name:$name" "/home/$name/.ssh/authorized_keys"
```

- root ログイン禁止

👇`sudo vim /etc/ssh/sshd_config`

```sh
#PermitRootLogin prohibit-password
PermitRootLogin no # rootでのログイン禁止
```

ssh 再起動:`sudo systemctl restart sshd`

### ssh 接続ならパスワードは禁止!

```sh
sudo adduser "$name" --gecos "" --disabled-password #デフォルトで作成 パスワードなし
passwd -d "$name"
```

👇`sudo visudo`

```sh
@includedir /etc/sudoers.d
```

最終行に追加

root 権限でしか閲覧できないように設定する

```sh
sudo -i # ubuntuの場合
sudo_dir="/etc/sudoers.d"
mkdir ${sudo_dir}
cd ${sudo_dir}
vim superUsers
```

👇`vim superUsers`

```sh
azureuser ALL=(ALL) NOPASSWD:ALL
```

のように追記すれば、このユーザーはパスワードなしで sudo が実行できる。
(パスワードさえわかれば、sudo が使えてしまうことを回避)

### 諸々必要そうなものまとめ

`cloud.init`

```sh
  # docker
  - apt install apt-transport-https ca-certificates curl software-properties-common -y
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  - apt update
  - apt install docker-ce docker-compose-plugin -y
  # Azure CLI
  # - apt remove azure-cli -y && sudo apt autoremove -y
  # - curl -sL https://aka.ms/InstallAzureCLIDeb | bash
  - apt install ca-certificates curl apt-transport-https lsb-release gnupg -y
  - curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
  - echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list
  - apt update
  - apt install azure-cli -y
  - az extension add --system --name containerapp
  - az extension add --system --name ad
    - az extension add --system --name application-insights
  # AzCopy
  - wget https://aka.ms/downloadazcopy-v10-linux -O azcopy.tgz
  - tar zxvf azcopy.tgz
  - cp azcopy_linux_amd64_*/azcopy /usr/local/bin/.
  - chmod og+x /usr/local/bin/azcopy
```

### firewall

pi-hole や nginx proxy manager の設定が一通り終わってから firewall の設定を行うこと

```sh
sudo ufw enable # firewall の有効化
sudo ufw status numbered # 番号をつけて、現在のfirewallの状態を確認
sudo ufw status verbose # 詳細表示
```
