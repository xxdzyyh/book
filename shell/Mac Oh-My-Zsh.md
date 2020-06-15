
### 安装

```
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

装好之后，会默认启动 git 插件，当你进入一个git管理的目录时，会显示当前的分支。

### 安装插件

插件列表:https://github.com/robbyrussell/oh-my-zsh/wiki/Plugins



> autojump 

```
brew install autojump

vi ~/.zshrc

plugins=(git autojump)

[[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh

source ~/.zshrc
```

可以使用 j 进行跳转。如果目录层次比较深，会比较方便，前提是目录在 history 中有记录



> Auto Suggestion

```
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

vim ~/.zshrc

plugins=(git zsh-autosuggestions)

source ~/.zshrc
```

启用 zsh-autosuggestions 后，在输入命令时会从 history 中找到最近的匹配的一条命令。





