### windows でも快適に使いたい

`git`をインストールして、
`gitbash`を使える状態にする

`gitbash`で基本的には操作していけば、
linux-like で諸々の操作を行っていく

まず windows での`$HOME` は `/c/Users/<ユーザー名>`になっていて `echo $HOME`でちゃんと確認できる

この$HOME に`.ssh` や `.gitconfig` を配置すれば、
linux 同様に動作してくれる

### alias

`git`って長いので、いつも通り`g`一発で操作できるようにする

```sh
cd
vim .bashrc
```

下記をまるまるコピー

[.bashrc](https://github.com/Katsuking/linux_settings/blob/main/.bashrc)

### git

これも alias の作成と同じ

```sh
cd
vim .gitconfig
```

[.gitconfig](https://github.com/Katsuking/linux_settings/blob/main/.gitconfig)に合わせて設定

### ssh

github 周りでも ssh 接続関連でも必須の設定
ここは、linux と同じやり方でいける
(`config`は設定しない)

暗号鍵と秘密鍵の作成

```sh
cd
mkdir .ssh
cd .ssh
ssh-keygen -t rsa # create keys
```
