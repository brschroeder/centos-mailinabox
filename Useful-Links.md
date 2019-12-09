**Editor**
See other docs

Add this to ~/.vimrc to get ShellCheck running in realtime

    if empty(glob('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall
    endif

    call plug#begin('~/.vim/plugged')

    Plug 'w0rp/ale'
    call plug#end()

**Markdown**
* [Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)

**Mail Server Testing**
* [Various tools](https://mxtoolbox.com)
* [DNS](http://pingability.com/zoneinfo.jsp)
* [DKIM and SPF](http://dkimvalidator.com/)
* [SSL/TLS Security](http://dkimvalidator.com/)

**Git / GitHub**
* [Visual/interactive cheatsheet](http://ndpsoftware.com/git-cheatsheet.html)
* [GitHub guides](https://guides.github.com)
* [Keeping a fork in sync with upstream repository](https://help.github.com/en/articles/syncing-a-fork)

**Python 3**

* [Installation on Redhat 7.x](https://developers.redhat.com/blog/2018/08/13/install-python3-rhel/)
* [Installation on CentOS 7.x](https://linuxize.com/post/how-to-install-python-3-on-centos-7/)
* [Example of appplicaton on CentOS 7.x and use of virtual environments](https://linuxize.com/post/install-odoo-11-on-centos-7/)
* [Intro to python on RHEL 8](https://developers.redhat.com/blog/2019/05/07/what-no-python-in-red-hat-enterprise-linux-8/)
* [Using Python on RHEL 8](https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/)

**RHEL Linux / Centos v8.0**
* [Application Streams](

**Comparing packages between distros**
* [pkgs.org](https://pkgs.org/)

**SELinux**
* [List of utilities](https://www.thegeekdiary.com/list-of-selinux-utilities/)
