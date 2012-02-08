function setup_prompt() {
    export PS1="[\[\e[0;34m\]\u\[\e[0m\]@\[\e[28;1m\]\[\e[0;32m\]\H \[\e[0m\]\w]\$ "
}
setup_prompt
PATH=$PATH:/sw/bin/:/var/lib/gems/1.8/bin
alias ttop='top -ocpu -R -F -s 2 -n30'
alias ls='ls -lh -G'
PROMPT_COMMAND='echo -ne "\033];`whoami`@`hostname -s`\007"'
