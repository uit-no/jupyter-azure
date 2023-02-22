# initialize conda for shell enviroment
myid=$UID
# do not do this for root
if [ $myid -ne 0 ]; then
    source /etc/bashrc
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/usr/local/anaconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/usr/local/anaconda/etc/profile.d/conda.sh" ]; then
            . "/usr/local/anaconda/etc/profile.d/conda.sh"
        else
            export PATH="/usr/local/anaconda/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
fi
unset myid
