SHELL = /bin/bash -o pipefail

#set -o nounset    # error when referencing undefined variable
#set -o errexit    # exit when command fails

include .env

UBUNTU_CODENAME := $(shell lsb_release -cs)

create-key:
	@test -f ~/.ssh/id_rsa.pub || ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ""
	cat ~/.ssh/id_rsa.pub

hello:
	@echo $(WelcomeMsg)

### Or use the following command to create a big file:
### dd if=/dev/zero of=/swap.img bs=1M count=4096
create-swap:
	@test -n "$(fileName)" || (echo ">> fileName flag is not set. e.g. fileName=swap.img"; exit 1)
	@test ! -f /$(fileName) || (echo ">> $(fileName) already exists"; exit 1)
	@test -n "$(size)" || (echo ">> size flag is not set. e.g. size=4G"; exit 1)
	sudo -u root sh -c '\
		test ! -f /$(fileName) \
		&& fallocate -l $(size) /$(fileName) \
		&& chown root:root /$(fileName) \
		&& chmod 0600 /$(fileName) \
		&& mkswap /$(fileName) \
		&& swapon /$(fileName) \
		&& echo "/$(fileName) none swap sw 0 0" >> /etc/fstab \
		&& echo "\n===\ncat /etc/fstab\n" \
		&& cat /etc/fstab \
		&& echo "\n===\nswapon --show /$(fileName)\n" \
		&& swapon --show /$(fileName) \
		&& echo "\n===\nfree -h\n" \
		&& free -h \
		&& echo "\n===\ncat /proc/meminfo | grep -i swap\n" \
		&& cat /proc/meminfo | grep -i swap \
		'

install-util:
	sudo -u root sh -c '\
		apt-get update \
		&& apt-get -y install make htop iotop tree sipcalc lynx \
		'

install-python:
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=3.8.2"; exit 1)
	sudo -H -u root sh -c '\
		apt-get update \
		&& apt-get -y install make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev  libncursesw5-dev xz-utils tk-dev \
		&& curl -L "https://www.python.org/ftp/python/$(version)/Python-$(version).tgz" -o Python-$(version).tgz \
		&& tar -zxvf Python-$(version).tgz \
		&& cd Python-$(version)/ \
		&& ./configure --enable-optimizations --with-ensurepip=install --enable-shared \
		&& make -j 8 \
		&& make altinstall \
		&& cd .. \
		&& rm -rf Python-$(version).tgz Python-$(version)/ \
		&& MAJOR_MINOR_VERSION=`echo "$(version)" | cut -d .  -f1,2` \
		&& find /usr/local/lib/python$${MAJOR_MINOR_VERSION}/ -not -perm /o=r -exec chmod o+r {} + \
		'

install-postgresql-server:
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=12"; exit 1)
	sudo -u root sh -c '\
		echo "deb http://apt.postgresql.org/pub/repos/apt/ $$(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
		&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
		&& apt-get update \
		&& apt-get -y install postgresql-$(version) \
		'

install-postgresql-client:
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=12"; exit 1)
	sudo -u root sh -c '\
		echo "deb http://apt.postgresql.org/pub/repos/apt/ $$(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
		&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
		&& apt-get update \
		&& apt-get -y install postgresql-client-$(version) \
		'

install-go:
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=1.15.7"; exit 1)
	sudo -u root sh -c '\
		rm -rf /usr/local/go \
		&& curl -L "https://golang.org/dl/go$(version).linux-amd64.tar.gz" -o go.tar.gz \
		&& tar -zxvf go.tar.gz -C /usr/local \
		&& rm -f go.tar.gz \
		'

install-golangci-lint:
	go get -u github.com/golangci/golangci-lint/cmd/golangci-lint

install-goreportcard:
	go get -u github.com/gojp/goreportcard/cmd/goreportcard-cli

install-staticcheck:
	go get -u honnef.co/go/tools/cmd/staticcheck

install-gosec:
	go get -u github.com/securego/gosec/cmd/gosec

install-gops:
	go get -u github.com/google/gops

install-semgrep:
	python3 -m pip install semgrep

# https://apt.llvm.org
# cat /etc/apt/sources.list
install-clangd:
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=9"; exit 1)
	sudo -u root sh -c '\
		wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add - \
		&& apt-add-repository "deb http://apt.llvm.org/$(UBUNTU_CODENAME)/ llvm-toolchain-$(UBUNTU_CODENAME)-$(version) main" \
		&& apt-get update \
		&& apt-get install -y clang-$(version) clangd-$(version) bear \
		'

install-cmake:
	sudo -u root sh -c '\
		apt-get install build-essential libssl-dev \
		&& cd /usr/local/src \
		&& wget https://github.com/Kitware/CMake/releases/download/v3.20.2/cmake-3.20.2-linux-x86_64.tar.gz \
		&& tar zxvf cmake-3.20.2-linux-x86_64.tar.gz \
		&& cd cmake-3.20.2 \
		&& ./bootstrap \
		&& make \
		&& make install \
		'

install-gcc:
	sudo -u root sh -c '\
		add-apt-repository ppa:ubuntu-toolchain-r/test \
		&& apt-get update \
		&& apt-get install gcc-9 g++-9 \
		'

install-git:
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=2.32.0"; exit 1)
	sudo -u root sh -c '\
		apt-get update \
		&& apt-get -y install make gcc dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext zlib1g-dev libssl-dev \
		&& apt-get -y install curl \
		&& cd /usr/local/src/ \
		&& curl -L https://github.com/git/git/archive/v$(version).tar.gz -o git.tar.gz \
		&& tar zxvf git.tar.gz \
		&& cd git-$(version)/ \
		&& make configure \
		&& ./configure --prefix=/usr \
		&& make all \
		&& make install \
		'

install-vim:
	sudo -u root sh -c '\
		apt-get update \
		&& apt-get -y remove vim vim-common vim-runtime vim-tiny \
		&& apt-get -y install libncurses5-dev python-dev python3-dev ruby-dev libperl-dev ruby-dev liblua5.3-dev exuberant-ctags cscope \
		&& ln -sfn /usr/include/lua5.3 /usr/include/lua \
		&& ln -sf /usr/lib/x86_64-linux-gnu/liblua5.3.so /usr/local/lib/liblua.so \
		&& rm -rf /usr/local/src/vim \
		&& cd /usr/local/src \
		&& git clone --depth 1 https://github.com/vim/vim.git \
		&& cd vim \
		&& ./configure \
		--prefix=/usr \
		--with-features=huge \
		--enable-multibyte \
		--enable-pythoninterp \
		--enable-python3interp \
		--enable-rubyinterp \
		--enable-perlinterp \
		--enable-luainterp \
		--enable-cscope \
		&& make \
		&& make install \
		&& hash -r \
		'

install-neovim:
	sudo -u root sh -c '\
		apt-get update \
		&& apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip \
		&& cd /usr/local/src \
		&& git clone --depth 1 https://github.com/neovim/neovim.git \
		&& cd neovim \
		&& make distclean \
		&& make CMAKE_BUILD_TYPE=Release \
		&& make install \
		&& find /usr/local/share/nvim/ -type d -exec chmod o+x {} + \
		'

uninstall-neovim:
	sudo -u root sh -c '\
		rm /usr/local/bin/nvim \
		&& rm -r /usr/local/share/nvim/ \
		'
# NOTE: cat /etc/apt/sources.list
install-docker:
	sudo -u root sh -c '\
		apt-get update \
		&& apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
		&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - \
		&& add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" \
		&& apt-get update \
		&& apt-get -y install docker-ce \
		&& usermod -aG docker $$(whoami) \
		'
	@#echo 'usermod -aG docker jun'
	@echo 'vim /etc/docker/daemon.json'

install-docker-compose:
	sudo -u root sh -c '\
		rm -f /usr/local/bin/docker-compose \
		&& curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose \
		&& chmod 755 /usr/local/bin/docker-compose \
		'

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
install-kubelet-kubeadm-kubectl:
	sudo -u root sh -c '\
		apt-get update \
		&& apt-get install -y apt-transport-https ca-certificates curl \
		&& curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
		&& echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
		&& apt-get update \
		&& apt-get install -y kubelet kubeadm kubectl \
		&& apt-mark hold kubelet kubeadm kubectl \
		&& kubectl completion bash >/etc/bash_completion.d/kubectl \
		'

#install-kubectl:
#	sudo -u root sh -c '\
#		curl -LO "https://dl.k8s.io/release/$$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
#		&& install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
#		&& kubectl completion bash >/etc/bash_completion.d/kubectl \
#		'

install-yarn:
	sudo -u root sh -c '\
		curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \
		&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list \
		&& apt update \
		&& apt install yarn \
		'

install-nvm:
	unset NVM_DIR && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.37.2/install.sh | bash

install-node:
	@test -f $$NVM_DIR/nvm.sh
	@test -n "$(version)" || (echo ">> version flag is not set. e.g. version=12.18.4"; exit 1)
	nvm install $(version) && nvm use $(version) && nvm alias default $(version)

# To upgrade Angular cli to the latest version:
# npm uninstall -g @angular/cli
# npm cache verify
# npm install -g @angular/cli@latest
# NOTE: https://stackoverflow.com/questions/43931986/how-to-upgrade-angular-cli-to-the-latest-version
install-angular:
	npm install -g @angular/cli

install-vue:
	command -v npm && npm install -g @vue/cli

install-termshark:
	sudo -u root sh -c '\
		apt-get install -y tshark \
		&& GO111MODULE=on /usr/local/go/bin/go get -u github.com/gcla/termshark/v2/cmd/termshark \
		'

setup-inode-watchers-for-open-files:
	sudo -u root sh -c '\
		echo fs.inotify.max_user_watches=19456 | tee -a /etc/sysctl.conf \
		&& sudo sysctl -p \
		'
