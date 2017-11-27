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

# backup existing hidden file and create symlink
function directReplace()
{
  local fromDirPath=$1
  local toDirPath=$2

  for fromPath in $fromDirPath/*; do
    local fromName=$(basename $fromPath)
    local toName=.$fromName
    local toPath=$toDirPath/$toName
    if [ -f $toPath ]; then
      info "backing up $toPath in $backup"
      mkdir -p $backup
      mv $toPath $backup
    fi
    info "creating link $toPath"
    ln -s $fromPath $toPath
  done
}

function forVim()
{
  local toDirPath=$1
  local toVimPath=$toDirPath/.vim/
  if [ -d $toVimPath ]; then
    info "backing up $toVimPath in $backup"
    mkdir -p $backup
    mv $toVimPath $backup
  fi
  curl -fLo .vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall
}

if [ "$#" -lt 1 ]; then
  echo "usage: $(basename $0) install_path"
  echo "  install in your home directory"
  exit 1
fi

absPath=$(readlink -f $0)
repoPath=${absPath%install.sh}
toPath=$(readlink -f $1)

if [ ! -d "$toPath" ]; then
  errorExit "not a valid install path '$toPath'"
fi

info "installing from $repoPath to $toPath"
directReplace $repoPath/files $toPath
forVim $toPath
