## 서버 설치 후 초기설정 정리

```sh

# 패키지 업데이트, 업그레이드, 자동 삭제
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove

# zsh 및 주 사용 패키지
sudo apt -y install zsh git htop btop neovim

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# 한국어 언어 팩
sudo apt -y install language-pack-ko

sudo locale-gen ko_KR.EUC-KR
sudo update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX

sudo apt -y install fonts-unfonts-core fonts-unfonts-extra fonts-nanum fonts-nanum-coding fonts-nanum-eco fonts-nanum-extra fonts-noto-cjk

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
bash ~/.fzf/install