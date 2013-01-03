#CC=/usr/bin/gcc-4.2
#PS1='\[\e[35;1m\]–(\[\e[0m\]\u\[\e[35;1m\]@\[\e[0m\]\H\[\e[35;1m\])–(\[\e[0m\]\j\[\e[35;1m\]|\[\e[0m\]\l\[\e[35;1m\])–(\[\e[0m\]\d\[\e[35;1m\]|\[\e[0m\]\T\[\e[35;1m\])— — -\n\[\e[35;1m\]–(\[\e[0m\]\w\[\e[35;1m\]): \[\e[0m\]'
PATH=$PATH:/sw/bin/:/var/lib/gems/1.8/bin:~/Bin

# Aliases
#alias gcc='/usr/bin/gcc-4.2'
alias ttop='top -ocpu -R -F -s 2 -n30'
alias ls='ls -lh -G'

alias pgstart='sudo -u postgres /opt/local/lib/postgresql92/bin/pg_ctl -D /opt/local/var/db/postgresql9/defaultdb start'
alias pgstop='sudo -u postgres /opt/local/lib/postgresql92/bin/pg_ctl stop'

alias apstart='sudo /opt/local/apache2/bin/apachectl start'
alias aprestart='sudo /opt/local/apache2/bin/apachectl restart'
alias apstop='sudo /opt/local/apache2/bin/apachectl stop'

alias mysqlstart="sudo \"cd /opt/local ; /opt/local/lib/mysql55/bin/mysqld_safe &\""
alias gpush='git svn rebase && git svn dcommit'

alias redis='redis-server /opt/local/etc/redis.conf'
function gclone() { git svn clone $@ -T trunk -b branches -t tags; }

PATH=/opt/local/bin:/opt/local/sbin:$PATH:$HOME/.rvm/bin:/opt/local/lib/mysql55/bin
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

##
# Your previous /Users/jcox/.bash_profile file was backed up as /Users/jcox/.bash_profile.macports-saved_2012-10-31_at_13:53:41
##

# MacPorts Installer addition on 2012-10-31_at_13:53:41: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.
 #[[ $- == *i* ]]   &&   . /Users/jcox/Code/git-prompt/git-prompt.sh
 [[ $- == *i* ]]   &&   . /Users/jcox/Code/PD.GitPrompt/git-prompt.sh

