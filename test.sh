
export PERL5LIB=$PERL5LIB:`pwd`/lib 

pkgs=(
the-nerd-tree
svg.vim
autocomplpop
gsession.vim
snipmate
)
for pkg in ${pkgs[*]};do
    vimana i $pkg
done
