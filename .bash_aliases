
#############################################
# 環境依存 env
#############################################

if [[ $(hostname) == "super" ]];then
	export dev="/media/external1/developement"
	export ssd='/media/external1'
	alias nv='${ssd}/appimage/nvim.appimage'
fi

if [[ $(hostname) == "main" ]]; then
	export dev="${HOME}/Desktop/development"
	export appimage="${HOME}/Desktop/appimage"
	alias nv="${appimage}/nvim.appimage --appimage-extract-and-run"
fi

alias py="python3"

#############################################
# utils
#############################################

# mkdir + cd
function mkdircd() {
	local name=${1}
	mkdir ${name} && cd ${name}
}
alias mkdircd=mkdircd

function mkdirtouch() {
	local path=${1}
	mkdir -p $(dirname ${path})
	touch ${path}
}
alias mkdirtouch=mkdirtouch
alias mkfile=mkdirtouch

alias xclip="xclip -selection c"
alias clip='xclip -selection c'

alias pwdc='pwd | clip'

function catc() {
        local filename="$1"
        cat $filename | clip
}

alias catc=catc

alias folder=nautilus
alias explorer=nautilus
alias du='du -h -s'

export VISUAL="vim"

export EDITOR='nv'

# alias git_push="sudo bash ${dev}/generalJob/git_cron/push.sh"

alias update='sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y'

# alias
function myalias() {
	sudo vim ~/.bash_aliases && source ~/.bashrc
	# git 管理しているディレクトリに飛ばす
	cp  ~/.bash_aliases ${dev}/wiki/linux
	cp  ~/.bash_aliases ${dev}/linux_settings
}

alias myalias=myalias

alias bashrc='sudo vim ~/.bashrc && source ~/.bashrc'

# alias absolutepath="cd $( dirname "${BASH_SOURCE[0]}" ) &> /dev/null && pwd"

#############################################
### fzf neovim
#############################################

alias ff="find . | fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias ffd="find . -type d | fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"

alias ffc="find . | fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down | clip"

function cdff() {
	# change dir using fzf
        local fp=$(ffd)
        if [[ "${fp}" != "." ]] && [[ -n ${fp} ]];then
                cd $fp && ll
                # activate python virtual env (venv)
                [[ $(ls | grep venv) == "venv" ]] && source 'venv/bin/activate'
        fi
}

alias cdff=cdff

function ffg() {
        local txt="$1"
        local fp=$(ff)
        if [[ -d ${fp} ]];then
                [[ -n $txt ]] && sudo grep "${txt}" --color=auto -r ${fp} 2>/dev/null
        elif [[ -f ${fp} ]];then
                [[ -n $txt ]] && sudo grep "${txt}" --color=auto -r $(dirname ${fp}) 2>/dev/null
        fi
}

alias ffg=ffg

function nf() {
        # change dir + open file with neovim
        local cmdarg=${1}
        [[ -z ${cmdarg} ]] && local fp=$(find . -type f | fzf --preview='less {}' --bind shift-up:preview-page-up,shift-down:preview-page-down)

	[[ -n ${cmdarg} ]]  && cd $(dirname ${cmdarg}) 2>/dev/null && nv "${cmdarg}"

	if [[ -n ${fp} ]];then
		cd $(dirname "${fp}")
		[[ $(ls | grep venv) == "venv" ]] && source 'venv/bin/activate'
		nv $(basename "${fp}" 2>/dev/null)
	fi

	# init.luaを編集した場合は、git管理ディレクトリへ飛ばす
	if [[ $(basename ${fp} 2>/dev/null ) == "init.lua" ]]; then
		cp -rp ~/.config/nvim/* "${dev}/vim"
	fi
}

alias nf=nf

function nfmemo() {
	local current_dir=$(pwd)
	nf ~/memo.md
	cd ${current_dir}
}

alias nfmemo=nfmemo

alias devnf="cd ${dev} && nf"

# change dir + open with vscode
function codeff() {
        local cmdarg=${1}
        [[ -z ${cmdarg} ]] && local fp=$(ff)

	if [[ -n ${cmdarg} ]];then 
		cd $(dirname ${cmdarg}) 2> dev/null && code .
	fi

        if [[ -f "${fp}" ]];then
                cd $(dirname "${fp}") && code . 
                [[ $(ls | grep venv) == "venv" ]] && source 'venv/bin/activate'
        fi
	
	if [[ -d "${fp}" ]];then
                cd ${fp} && code . 
                [[ $(ls | grep venv) == "venv" ]] && source 'venv/bin/activate'
        fi
}

alias codeff=codeff 

#############################################
### git
#############################################

function gitup() {
	local cwd=$(pwd)
	local rootdir=$(git rev-parse --show-toplevel 2>/dev/null)
	if [[ -n ${rootdir} ]];then
		git status
		echo
		BRANCH=$(git symbolic-ref --short HEAD)
		read -p "Do you want to push all changes to ${BRANCH}? (y/n) " answer
		if [[ "$answer" == "y" || "$answer" == "Y" ]];then
			git pull origin ${BRANCH}
			source ~/.env # read env vars of email/user
               		git config --global user.email "${USER_EMAIL}"
               		git config --global user.name "${USER_NAME}"
			git add -A
               		git commit -m "Manual update!"
               		git push origin ${BRANCH}:${BRANCH}
		fi
	else
		echo "could not find a git root directory!"
	fi
}

alias gitup=gitup

# git のroot dirを配列で用意
git_root=(
    "${dev}/generalJob"
    "${dev}/docker-compose"
    "${dev}/python_for_fun"
    "${dev}/wiki"
    "${dev}/javascriptProjects"
    "${dev}/linux_settings"
)

function gitpullall() {
	for root_dir in "${git_root[@]}"
	do
		cd ${root_dir}
	        BRANCH=$(git symbolic-ref --short HEAD)
		git pull origin ${BRANCH}
	done
}

function gitpushall() {
	source ~/.env
	for root_dir in "${git_root[@]}"
	do
		if [ -d "$root_dir/.git" ]; then
			cd "${root_dir}"
			git status
			echo
			BRANCH=$(git symbolic-ref --short HEAD)
			read -p "Do you want to push all changes inside $(basename ${root_dir}) dir to ${BRANCH}? (y/n) " answer
			if [[ "$answer" == "y" || "$answer" == "Y" ]]; then		
	   			git pull origin ${BRANCH}
	   	     		git config --global user.email "${USER_EMAIL}"
	   	     		git config --global user.name "${USER_NAME}"
	   	     		git add -A
	   	     		git commit -m "daily update!"
	   	     		git push origin ${BRANCH}:${BRANCH}
			else
				echo "Skipping ${root_dir} brannch: ${BRANCH}"
				continue
			fi
	    	else
			echo "Could not find git in this dir: ${root_dir}"
	        	continue
	   	fi
	done
}


#############################################
# Makefile 
#############################################

# create Makefile template for python
function pymakefile() {

	[[ ! -f $(pwd)/requirements.txt ]] && touch "$(pwd)/requirements.txt"

	[[ ! -f "$(pwd)/Makefile" ]] && cat << 'EOF' > "$(pwd)/Makefile"
VENV = venv
PYTHON = $(VENV)/bin/python3
PIP = $(VENV)/bin/pip

run: $(VENV)/bin/activate
	$(PYTHON) main.py

$(VENV)/bin/activate: requirements.txt
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.txt

clean:
	rm -rf __pycache__
	rm -rf $(VENV)

EOF
}

alias pymakefile=pymakefile

function dockermakefile() {
	[[ ! -f "$(pwd)/docker-compose.yaml" ]] && touch "$(pwd)/docker-compose.yaml"  
	[[ ! -f "$(pwd)/Makefile" ]] && cat << 'EOF' > "$(pwd)/Makefile"
COMPOSE:=docker-compose.yml
.PHONY: up down

up: ${COMPOSE}
	docker compose up -d

down: ${COMPOSE}
	docker compose down
	docker ps -a
EOF

}

alias dockermakefile=dockermakefile



# mv a custom script to /usr/local/bin
# user defined script
function userdefinedscript() {
	local script=${1}
	sudo cp ${script} "/usr/local/bin"
	sudo chmod 750 "/usr/local/bin/${script}"
	echo "copied to /usr/local/bin"
	read -p "Do you want to change dir to /usr/local/bin ? (y/n) " answer
	[[ "$answer" == "y" || "$answer" == "Y" ]] && cd "/usr/local/bin"
}

alias userdefinedscript=userdefinedscript

#############################################
# ssh 
#############################################

alias sshconfig='nv ~/.ssh/config'
alias nvconfig='nv ~/.ssh/config'

function scpmain() {
	local item=$1
	scp -r ${item} main:~/backup
}

alias scpmain=scpmain

# change background
alias slideshow_on="bash ${dev}/generalJob/tool/wallpaper.sh &"
alias slideshow_off="bash ${dev}/generalJob/tool/kill_script_process.sh wallpaper.sh"

# monitor size
alias monitor_size="cat /sys/class/graphics/*/modes"

# godot
godot_path="/media/external1/developement/godotProjects"
alias godot="cd ${godot_path} && pwdc  && folder ${godot_path}"

#############################################
# extract
#############################################

alias unzipall='find ./ -type f  -name "*.zip" -exec unzip {} \;' 
alias unrarall='find ./ -type f  -name "*.zip" -exec unrar x {} \;' 


