#!/bin/bash

# ==========================================
# 設定変数 (Variables) - 必要に応じて書き換えてください
# ==========================================

# ブラウザでWEBを開く関数
function openweb {
    xdg-open "$1" >/dev/null 2>&1 &
}

# Determine script directory safely
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
# EMAIL="your_email@example.com"
ALIASES_URL="https://raw.githubusercontent.com/Katsuking"
# color
CYAN='\033[1;36m'
NC='\033[0m' # Reset color
EXTS='extensions.txt'

echo "=== Antigravity の存在確認 ==="

# command -v でコマンドが存在するかチェック。出力（標準出力・エラー）はすべてゴミ箱へ。
if ! command -v antigravity &> /dev/null; then
    echo "------------------------------------------------------------"
    echo "[エラー] 'antigravity' コマンドが見つかりません。"
    echo "        antigravityのインストールを完了させてください。"
    echo "------------------------------------------------------------"
    
    openweb https://antigravity.google/
    exit 1
fi

if ! command -v code &> /dev/null; then
    echo "------------------------------------------------------------"
    echo "[エラー] 'code' コマンドが見つかりません。"
    echo "        VS Code をインストールし、'code' コマンドがパスにあることを確認してください。"
    echo "------------------------------------------------------------"
    openweb https://code.visualstudio.com/download
    exit 1
fi

# 一時ディレクトリを作成 終了時に削除
echo "creating temporary directory..."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
tmp=$(mktemp -p "$tmpdir") # 一時ディレクトリ内に一時ファイル作成

echo "=== Starting System Setup Script ==="

# ====================================
# antigravity setup
# ====================================

curl -fsSL \
  "${ALIASES_URL}"/linux_settings/main/vscode_setting.json \
  -o "$tmp"

# Antigravityのsettings.jsonを設定
find ~/.config -type f -path "*/Antigravity/*settings.json" -print0 | \
while IFS= read -r -d '' file; do
    echo "antigravityのsettings.jsonの場所: $file"
    cp "$tmp" "$file"
done

# install extensions
echo "[OK] Antigravity が見つかりました。拡張機能のインストールに進みます。"
while IFS= read -r extension || [ -n "$extension" ]; do
    extension="$(echo "$extension" | xargs)"
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue # skip empty lines and comments
    echo "Installing Antigravity extension: $extension"
    if ! antigravity --install-extension "$extension"; then
        echo "⚠️ $extension のインストールに失敗しました"
    fi
done < "${SCRIPT_DIR}/${EXTS}"

# ====================================
# vscode setup
# ===============================

# vscode も同様に
find ~/.config -type f -path "*/Code/User/settings.json" -print0 |
while IFS= read -r -d '' file; do
    echo "settings.json の場所: $file"
    cp "$tmp" "$file"
done

# install extensions
echo "[OK] vscode が見つかりました。拡張機能のインストールに進みます。"
while IFS= read -r extension || [ -n "$extension" ]; do
    extension="$(echo "$extension" | xargs)"
    [[ -z "$extension" || "$extension" =~ ^# ]] && continue # skip empty lines and comments
    echo "Installing vscode extension: $extension"
    if ! code --install-extension "$extension"; then
    echo "⚠️ $extension のインストールに失敗しました"
fi
done < "${SCRIPT_DIR}/${EXTS}"



# システムの更新 (System Update)
sudo apt update && sudo apt upgrade -y

# ====================================
# 必要なパッケージのインストール
# ====================================

sudo apt install -y \
    curl \
    git \
    build-essential \
    vim \
    fzf \
    xclip \
    ibus-mozc \
    direnv \
    net-tools
    # nvidia-cuda-toolkit \

sudo snap install chromium

# GNOME環境（GNOME) で正しく設定されているか確認
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'jp'), ('ibus', 'mozc-jp')]"
echo "GNOME環境 入力ソース $(gsettings get org.gnome.desktop.input-sources sources)"

sudo timedatectl set-timezone Asia/Tokyo
echo "システム時刻を東京に設定: $(timedatectl | grep "Time zone")"

# ====================================
# ツールインストール web
# ====================================

openweb https://docs.docker.com/engine/install/ubuntu/ >/dev/null 2>&1
openweb https://www.openshot.org/ja/ >/dev/null 2>&1
openweb https://github.com/settings/keys # SSH鍵の登録用

# ====================================
# git setup
# ====================================

echo "=== Git Configuration ==="

if curl -fsSL ${ALIASES_URL}/linux_settings/refs/heads/main/.gitconfig -o ~/.gitconfig; then
    echo "[OK] .gitconfig has been successfully installed!"
else
    echo "[ERROR] Failed to download .gitconfig."
fi


echo -e "\n[OK] Git configuration complete!"

# ====================================
# SSH鍵の生成 (Generate SSH Key)
# ====================================

# ※すでに鍵が存在している場合は上書きしないように判定を入れています
# 最新の暗号に適宜変更すること
if [ ! -f ~/.ssh/id_ed25519 ]; then
    echo "Generating a new SSH key (Ed25519)..."
    ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519
    echo "------------------------------------------------"
    echo "【重要 / IMPORTANT】"
    echo "Your SSH Public Key has been generated. Copy the text below and add it to GitHub:"
    cat ~/.ssh/id_ed25519.pub
    echo "------------------------------------------------"
else
    echo "SSH key already exists. Skipping generation."
fi

# ====================================
# neovim
# ====================================

echo "=== Installing Neovim via Official PPA ==="

# Check if Neovim is already installed
if ! command -v nvim &> /dev/null; then
    # 公式の最新安定版（Stable）を確実にダウンロード
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    # 解凍して /opt に安全に配置
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    # シンボリックリンクを作成してコマンドを有効化
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    # 不要になった圧縮ファイルを削除
    rm nvim-linux-x86_64.tar.gz
else
    echo "[INFO] Neovim is already installed. Skipping installation process."
    echo "* To update it in the future, simply run 'sudo apt update && sudo apt upgrade'."
fi
mkdir -p ~/.config/nvim && curl -fLo ~/.config/nvim/init.lua "${ALIASES_URL}"/vim/refs/heads/main/init.lua # install init.lua

echo "=== Setup Completed! ==="

# Cleanup
sudo apt autoremove -y && sudo apt clean
