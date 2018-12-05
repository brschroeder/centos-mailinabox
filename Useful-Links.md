**Editor**
add this to ~/.vimrc to get ShellCheck running in realtime

    if empty(glob('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall
    endif

    call plug#begin('~/.vim/plugged')

    Plug 'w0rp/ale'
    call plug#end()

**Git/GitHub**
* [Visual/interactive cheatsheet](http://ndpsoftware.com/git-cheatsheet.html)
* [GitHub guides](https://guides.github.com) 

**Python 3**

* [Installation on Redhat](https://developers.redhat.com/blog/2018/08/13/install-python3-rhel/)
* [Installation on CentOS](https://linuxize.com/post/how-to-install-python-3-on-centos-7/)
* [Example of appplicaton on CentOS and use of virtual environments](https://linuxize.com/post/install-odoo-11-on-centos-7/)


