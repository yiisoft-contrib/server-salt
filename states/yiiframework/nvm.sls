#
# Install nodejs nvm
# https://github.com/nvm-sh/nvm#git-install
#
nvm_git:
  git.latest:
    - name: https://github.com/nvm-sh/nvm.git
    - rev: v0.39.1
    - target: /opt/nvm
    - force_reset: True
    - force_checkout: True

# https://github.com/nvm-sh/nvm#git-install
/etc/profile.d/nvm.sh:
  file.managed:
    - contents: |
        export NVM_DIR="/opt/nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# install node 13.x
install_nodejs:
  cmd.run:
    - name: nvm install 13
    - onlyif: nvm ls 13 --no-colors |grep 'N/A'
