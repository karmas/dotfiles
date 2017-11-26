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
  fromDirPath=$1
  toDirPath=$2

  for fromPath in $fromDirPath/*; do
    fromName=$(basename $fromPath)
    toName=.$fromName
    toPath=$toDirPath/$toName
    if [ -f $toPath ]; then
      info "backing up $toPath in $backup"
      mkdir -p $backup
      mv $toPath $backup
    fi
    info "creating link $toPath"
    ln -s $fromPath $toPath
  done
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
