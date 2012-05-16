PS1='\[\e[30;1m\]–(\[\e[0m\]\u\[\e[30;1m\]@\[\e[0m\]\H\[\e[30;1m\])–(\[\e[0m\]\j\[\e[30;1m\]|\[\e[0m\]\l\[\e[30;1m\])–(\[\e[0m\]\d\[\e[30;1m\]|\[\e[0m\]\T\[\e[30;1m\])— — -\n\[\e[30;1m\]–(\[\e[0m\]\w\[\e[30;1m\]): \[\e[0m\]'
PATH=$PATH:/sw/bin/:/var/lib/gems/1.8/bin:~/Bin

alias ttop='top -ocpu -R -F -s 2 -n30'
alias ls='ls -lh -G'
alias pgstart='sudo -u postgres /opt/local/lib/postgresql90/bin/pg_ctl -D /opt/local/var/db/postgresql9/defaultdb start'
alias gpush='git svn rebase && git svn dcommit'

export PATH=/opt/subversion/bin/:/opt/local/bin:/opt/local/sbin:$PATH
[[ -s "/Users/jordantcox/.rvm/scripts/rvm" ]] && source "/Users/jordantcox/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
