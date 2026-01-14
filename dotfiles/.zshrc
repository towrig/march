# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme (see https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
ZSH_THEME="robbyrussell"

# Uncomment to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment to use hyphen-insensitive completion (- and _ interchangeable)
# HYPHEN_INSENSITIVE="true"

# Uncomment to disable auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change auto-update frequency (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Uncomment to enable command auto-correction
# ENABLE_CORRECTION="true"

# Uncomment to display red dots while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment to disable marking untracked files under VCS as dirty
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# History timestamp format (see 'man strftime')
# HIST_STAMPS="mm/dd/yyyy"

# Custom folder (default $ZSH/custom)
# ZSH_CUSTOM=/path/to/new-custom-folder

# Plugins (see https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins)
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor
# export EDITOR='nano'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Aliases
# alias zshconfig="nano ~/.zshrc"
# alias ohmyzsh="nano ~/.oh-my-zsh"

# Run fastfetch on interactive shell startup
if [[ $- == *i* ]]; then
  fastfetch
fi

