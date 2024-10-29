#!/bin/bash
# basic utils
#https://raw.githubusercontent.com/inflatebot/runpod-init/refs/heads/main/runpod-init.sh

#### Install Scripts
## Tools of Trade
install-axolotl() {
	cd /workspace || exit
	# burg time
	git clone https://github.com/axolotl-ai-cloud/axolotl
	cd axolotl || exit
	# checkout current working commit
	git checkout 6d9a3c4d817cd57e702b270c04d2b2d2400c3ad4
	python3 -m venv venv; source venv/bin/activate
	pip3 install packaging ninja
	pip3 install -e '.[flash-attn,deepspeed]'
}

install-llamafactory() {
	cd /workspace || exit
	git clone --depth 1 https://github.com/hiyouga/LLaMA-Factory.git
	cd LLaMA-Factory || exit
	deps=$(TERM=screen-256color whiptail \
 	--title "LlamaFactory Dependencies" \
 	--inputbox "Select which extra dependencies, as a comma separated list with no spaces, to pass to pip from these available ones (torch and metrics are required):\n\
	\"torch,metrics,torch-npu,deepspeed,liger-kernel,bitsandbytes,hqq,eetq,gptq,\nawq,aqlm,vllm,galore,badam,adam-mini,qwen,modelscope,openmind,quality\"" 16 80 \
	"torch,metrics,adam-mini,deepspeed,liger-kernel,bitsandbytes,hqq" \
 	3>&1 1>&2 2>&3) && echo "$deps"
	python3 -m pip install -e ".[$deps]"
	#echo -e "---\nSelect which extra dependencies, as a comma separated list with no spaces, to pass to pip from these available ones (torch and metrics are required):\ntorch,metrics,torch-npu,deepspeed,liger-kernel,bitsandbytes,hqq,eetq,gptq,awq,aqlm,vllm,galore,badam,adam-mini,qwen,modelscope,openmind,quality\n---\n"
	#read -e -i "torch,metrics,adam-mini,deepspeed,liger-kernel,bitsandbytes,hqq" -p "$PS2 " deps
}

install-llamacpp() {
	cd /workspace || exit
	git clone https://github.com/ggerganov/llama.cpp.git
	cd llama.cpp || exit
	export LLAMA_CPP_DIR=/workspace/llama.cpp
	make GGML_CUDA=1 -j 8 
	# set up venv for lcpp
	python3 -m venv venv; source venv/bin/activate
	python3 -m pip install -r requirements.txt
}

install-mergekit() {
	cd /workspace || exit
	git clone https://github.com/arcee-ai/mergekit.git
	cd mergekit || exit
	python3 -m venv venv; source venv/bin/activate
	pip install -e .
}

install-vllm() {
	cd /workspace || exit
	mkdir vllm
	cd vllm || exit
	python3 -m venv venv; source venv/bin/activate
	pip install vllm
}

install-aphrodite() {
	cd /workspace || exit
	mkdir aphrodite
	cd aphrodite || exit
	python3 -m venv venv; source venv/bin/activate
	pip install aphrodite-engine
}

## Utilities

install-micro() {
	cd /usr/bin || exit
	curl https://getmic.ro | bash
}

install-bottom() {
	asset_url=$(curl -s "https://api.github.com/repos/ClementTsang/bottom/releases/latest" | jq -r '.assets[] | select(.name | endswith("_amd64.deb") and (contains("musl") | not)) | .browser_download_url')
	curl -L $asset_url -o /tmp/bottom-latest.deb
	dpkg -i /tmp/bottom-latest.deb
}

install-gotop() {
	asset_url=$(curl -s "https://api.github.com/repos/xxxserxxx/gotop/releases/latest" | jq -r '.assets[] | select(.name | endswith("_amd64.deb") and (contains("musl") | not)) | .browser_download_url')
	curl -L $asset_url -o /tmp/gotop-latest.deb
	dpkg -i /tmp/gotop-latest.deb
}

### Essentials
clear
echo -e "\
################################################################################\n\
Welcome! This script helps set up the basic tools needed for the LLM work\n\
we do at Allura. This script will do the following:\n\
    - Set HF_HOME to '/workspace', so models get downloaded to the larger \n\
	    (and persistent) volume storage.\n\
    - Unminimize the environment to make more packages available.\n\
    - Install 'jq' and 'whiptail' which will be used later in the script.\n\
	- Provide some prompts to install Python tools and system utilities.\n\
	- Ask you for your HF token and log you into HuggingFace.\n\
	- Give you a script to use (on Linux only until I figure it out for Windows)\n\
        to mount the container and volume storage locally via SSHFS.\n\
Press Enter to continue.\n\
################################################################################"
read 
export HF_HOME=/workspace
yes | unminimize 
apt update
apt install -y whiptail jq
pip install huggingface_hub[cli]
git config --global credential.helper store

#TOOL_DIR=$(TERM=ansi whiptail --title "Tool Directory" --inputbox "Where should we put Python tools? \
#Default is /workspace so that configs and artifacts you put in them stay persistent; but if you're providing configs \
#externally (e.g. via SSHFS), it may make more sense to put them in container storage, \
#since you'll have to reinstall them when the pod is restarted anyway." 20 78 "/workspace" 3>&1 1>&2 2>&3)

TOOLS=$(TERM=screen-256color whiptail --title "Tools" --checklist \
"Pick some tools to install (select with Space, confirm with Enter)" 20 78 10 \
"axolotl" "Axolotl" OFF \
"llamafactory" "LlamaFactory" OFF \
"llamacpp" "llama.cpp" OFF \
"vllm" "vLLM" OFF \
"aphrodite" "Aphrodite Engine" OFF \
"mergekit" "MergeKit" OFF \
3>&1 1>&2 2>&3)

for tool in $TOOLS; do
	eval "install-$tool"
done

UTILITIES=$(TERM=screen-256color whiptail \
 --title "Utilities" \
 --checklist \
"Pick some utilities to install (select with Space, confirm with Enter)" 20 78 10 \
"mosh" "The cooler SSH; requires mosh-client installed on your system" OFF \
"tmux" "Terminal multiplexer; lets you have more terminal per terminal" OFF \
"nano" "The only text editor you need (I promise)" OFF \
"micro" "The cooler nano https://micro-editor.github.io/" OFF \
"emacs" "Text editor for nerds" OFF \
"vim" "Text editor for masochists" OFF \
"htop" "Your dad's process monitor" OFF \
"gotop" "The cool kids' process monitor" OFF \
"bottom" "Fizz's process monitor" OFF \
"nvtop" "Process monitor for GPUs" OFF \
3>&1 1>&2 2>&3)
echo $UTILITIES
for utility in $UTILITIES; do
	eval "install-$utility" || apt update && apt install -y "${utility//\"}" || echo "Don't know how to install $utility. Yell at Bot about it."
done

EXTRAS=$(TERM=screen-256color whiptail --title "Extras" --inputbox "If you want to install any other packages, specify them here as a space-separated list." 20 78 3>&1 1>&2 2>&3)
apt install -y "$EXTRAS"

#### HF Login

HFTOKEN=$(TERM=screen-256color whiptail --title "HF Token" --passwordbox "Paste your HF token here (yes it will be masked, calm)" 8 78 3>&1 1>&2 2>&3)

if [[ $HFTOKEN ]]; then
	# this "yes" shouldn't be necessary but fuck it we ball
	yes | huggingface-cli login --token "$HFTOKEN" --add-to-git-credential
fi

# Ask to set up tmux plugin manager
if [[ $(which tmux) ]]; then
	if TERM=screen-256color whiptail --title "tmux-sensible" --yesno \
	"You installed tmux; should we set up Tmux Plugin Manager and tmux-sensible to add some nice defaults?\n\
	https://github.com/tmux-plugins/tpm\n" 8 78; then
		mkdir -p ~/.tmux/plugins
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins
		curl https://raw.githubusercontent.com/inflatebot/runpod-init/refs/heads/main/tmux.conf -o ~/.tmux.conf
	fi
fi

# TODO:
# - add default tmux config if it was installed
# - set up conda
# - prompt if utilities should be installed in workspace or home

SSHFS_STRING="mkdir -p ~/runpod-mounts/runpod-$RUNPOD_POD_ID/{home,workspace} && sshfs root@$RUNPOD_PUBLIC_IP:/root ~/runpod-mounts/runpod-$RUNPOD_POD_ID/home -p $RUNPOD_TCP_PORT_22 -o IdentityFile=~/.ssh/id_ed25519 && sshfs root@$RUNPOD_PUBLIC_IP:/workspace ~/runpod-mounts/runpod-$RUNPOD_POD_ID/workspace -p $RUNPOD_TCP_PORT_22 -o IdentityFile=~/.ssh/id_ed25519"

TERM=screen-256color whiptail --title "Done" --msgbox --ok-button "Thanks" \
"All done! Oh, by the way, if you're not using SSHFS, it'll save you a lot of time.\n\
Here's a command to make a mountpoint for the current pod and mount its filesystem there.\n\
This creates 2 mount points in your home folder and mounts them with SSHFS. (SSHFS exists for Windows, but\
this command probably only works on Linux. Soz.)\n\n\
It's also been put in ~/sshfs-command.\n\n
$SSHFS_STRING
" \
 20 100

echo -e "###\nUse the following to mount /workspace and /root via SSHFS (assuming you used an ed25519 SSH key to log in, which you should): \n\n$SSHFS_STRING\n\n###" > ~/sshfs-command