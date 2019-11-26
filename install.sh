#! /bin/bash

function info()
{
  echo :info: $*
}

function errorExit()
{
  echo :error: $*
  exit 2
}

backup=backup-$(date +%T).tmp

function directReplace()
{
  local fromDirPath=$1
  for fromPath in $fromDirPath/*; do
    local fromName=$(basename $fromPath)
    local toName=.$fromName
    local toPath=$installPath/$toName
    if [ -f $toPath -o -h $toPath ]; then
      info "backup $toPath in $backup"
      mkdir -p $backup
      mv $toPath $backup
    fi
    info "link $toPath -> $fromPath"
    ln -s $fromPath $toPath
  done
}

function forVim()
{
  local toVimPath=$installPath/.vim/
  if [ -d $toVimPath ]; then
    info "backup $toVimPath in $backup"
    mkdir -p $backup
    mv $toVimPath $backup
  fi

  curl -fLo $installPath/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  vim +PlugInstall +qall

  local toIndentPath=$installPath/.vim/indent
  mkdir -p $toIndentPath
  local fromPath=$repoPath/forvim/cpp.vim
  local toPath=$toIndentPath/cpp.vim
  info "link $toPath -> $fromPath"
  ln -s $fromPath $toPath
}

if [ "$#" -lt 1 ]; then
  echo "usage: $(basename $0) install-dir"
  echo "  install in your home directory"
  exit 1
fi

repoPath=${0%install.sh}
installPath=$1

if [ ! -d "$installPath" ]; then
  errorExit "install directory not found '$installPath'"
fi

directReplace $repoPath/forhome
forVim

info "sample gitconfig file in $repoPath/tocopy/gitconfig"
