# Gogs web hosting for YunoHost

This YunoHost App take an existing Gogs repository with a static site and serve it with nginx.
At each commit the site will be updated by a git hook.

Gogs is a self-hosted Git service written in Go. Alternative to Github.
- [Gogs website](http://gogs.io)
- [Gogs package for YunoHost](https://github.com/YunoHost-Apps/gogs_ynh)

## Requirements
- A functional instance of [YunoHost](https://yunohost.org)
- [Gogs package](https://github.com/YunoHost-Apps/gogs_ynh) must be installed
- The repository that you want to serve must exist in Gogs

## Installation
From the command-line:

`sudo yunohost app install -l MySite https://github.com/YunoHost-Apps/gogs_webhost_ynh`

## Upgrade
From the command-line:

`sudo yunohost app upgrade -u https://github.com/YunoHost-Apps/gogs_webhost_ynh gogswebhost`

## Info

- [YunoHost forum thread](https://forum.yunohost.org/)
- The post-receive hook of your Gogs repository will be overwritten at install and at each upgrade.
- You can't use the app to host 2 time the same repository (because of the previous point).
- There is no check that the branch and the directory you wish to serve exist in your repo, you must ensure that they exist before installing the app.
- Your site must have an index.html.
- If your site contain absolute links (like href=""/asset/something.js") this will only work on a domain root.

## License

This package is published under the MIT License.
