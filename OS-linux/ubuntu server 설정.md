## 서버 설치 후 초기설정 정리

```sh

# root만 있고 일반 계정이 없다면 계정 생성
sudo adduser florist
sudo usermod -aG sudo florist
su - florist
sudo echo "이 계정은 sudo가 됩니다"

# 패키지 업데이트, 업그레이드, 자동 삭제
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove

# zsh 및 주 사용 패키지
sudo apt install -y zsh git htop btop stow curl eza bat zoxide
sudo apt install -y software-properties-common # for add-apt-repository
sudo apt install -y net-tools # ifconfig, netstat, ...

# batcat 대신 bat 사용
sudo ln -s /usr/bin/batcat /usr/bin/bat

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# starship
curl -fsSL https://starship.rs/install.sh | sh

# fastfetch
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update

sudo apt install fastfetch

# 한국어 언어 팩
sudo apt -y install language-pack-ko

sudo locale-gen ko_KR.EUC-KR
sudo update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX

sudo apt -y install fonts-unfonts-core fonts-unfonts-extra fonts-nanum fonts-nanum-coding fonts-nanum-eco fonts-nanum-extra fonts-noto-cjk

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
bash ~/.fzf/install

# dotfiles
git clone https://github.com/leafbird/dotfiles ~/dotfiles
bash ~/dotfiles/script/setup.sh

# neovim
sudo apt -y install neovim build-essential fd-find ripgrep # build-essential for gcc

# fdfind 대신 fd 사용
#sudo ln -s /usr/bin/fdfind /usr/bin/fd
sudo ln -s /usr/lib/cargo/bin/fd /usr/bin/fd

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# docker --------------------------------------------
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Install Docker:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# sudo 명령 없이 docker 실행 가능하게 하기
sudo usermod -aG docker $USER
logout

# lazydocker --------------------------------------------
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
sudo ln -s ~/.local/bin/lazydocker /usr/bin/lazydocker
lazydocker --version
```

# ssh port 변경
```sh
sudo nvim /etc/ssh/sshd_config
# Port 22 
Port 23
sudo systemctl restart sshd
```