#!/bin/bash
# basic utils
#https://raw.githubusercontent.com/inflatebot/runpod-init/refs/heads/main/runpod-init.sh

basic() {
	export HF_HOME=/workspace
	yes | unminimize 
	apt install -y nano tmux htop nvtop whiptail
	pip install huggingface_hub[cli]
	git config --global credential.helper store
}

hf-login() {
	yes | huggingface-cli login
}

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
	tput bel
	echo -e "---\nSelect which extra dependencies, as a comma separated list with no spaces, to pass to pip from these available ones (torch and metrics are required):\ntorch,metrics,torch-npu,deepspeed,liger-kernel,bitsandbytes,hqq,eetq,gptq,awq,aqlm,vllm,galore,badam,adam-mini,qwen,modelscope,openmind,quality\n---\n"
	read -e -i "torch,metrics,adam-mini,deepspeed,liger-kernel,bitsandbytes,hqq" -p "$PS2 " deps
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

basic

whiptail --title "Test" --infobox "Whiptail works!" 80 80


# set up ggify
#cd /workspace
#git clone https://github.com/akx/ggify.git
#cd ggify
#python3 -m pip install -e .
#cd ..

