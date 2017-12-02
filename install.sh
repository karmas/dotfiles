function info()
{
  echo "(info) $*"
}

function errorExit()
{
  echo "(error) $*"
  exit 2
}

backup=backup-$(date +%s)

function directReplace()
{
  local fromDirPath=$1
  for fromPath in $fromDirPath/*; do
    local fromName=$(basename $fromPath)
    local toName=.$fromName
    local toPath=$installPath/$toName
    if [ -f $toPath -o -h $toPath ]; then
      info "backing up $toPath in $backup"
      mkdir -p $backup
      mv $toPath $backup
    fi
    info "creating link $toPath -> $fromPath"
    ln -s $fromPath $toPath
  done
}

function forVim()
{
  local toVimPath=$installPath/.vim/
  if [ -d $toVimPath ]; then
    info "backing up $toVimPath in $backup"
    mkdir -p $backup
    mv $toVimPath $backup
  fi
  curl -fLo .vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall

  local toIndentPath=.vim/indent
  mkdir -p $toIndentPath
  local fromPath=$repoPath/forvim/cpp.vim
  local toPath=$toIndentPath/cpp.vim
  info "creating link $toPath -> $fromPath"
  ln -s $fromPath $toPath
}

if [ "$#" -lt 1 ]; then
  echo "usage: $(basename $0) install_path"
  echo "  install in your home directory"
  exit 1
fi

absPath=$(readlink -f $0)
repoPath=${absPath%install.sh}
installPath=$(readlink -f $1)

if [ ! -d "$installPath" ]; then
  errorExit "not a valid install path '$installPath'"
fi

directReplace $repoPath/forhome
forVim

info "sample gitconfig file in $repoPath/tocopy/gitconfig"
