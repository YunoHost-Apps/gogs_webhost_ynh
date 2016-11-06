#
# Common variables
#

APPNAME="gogswebhost"
app=${YNH_APP_INSTANCE_NAME:-gogswebhost}
DESTDIR="/var/www/"${app}

# Source YunoHost helpers
source /usr/share/yunohost/helpers

#
# Common helpers
#

pre_install() {
  local GOGSREPO=$1
  local RESTORE=${2:-none}

  repo_path="/home/gogs/repositories/"$GOGSREPO".git"

  # TODO better check that gogs is installed
  sudo [ -d "/opt/gogs" ] \
      || ynh_die "Gogs is not installed"

  # Check domain/path availability
  sudo yunohost app checkurl "${domain}${path}" -a "$app" \
      || ynh_die "Path not available: ${domain}${path}"

  if [ "$RESTORE" = "--restore" ]
  then
    # Restore the app and data files
    sudo cp -a ./www "$DESTDIR"
    # Restore directories and permissions
    sudo chown -R "gogs:gogs" "$DESTDIR"
  else
    # TODO check format user/repo
    # Check that the gogs repository exist
    sudo [ -d "$repo_path" ] \
        || ynh_die "The gogs repository "${gogsrepo}" does not exist"
  fi
  }

install_site() {
  local DOMAIN=$1
  local YNH_PATH=$2
  local REPO_PATH=$3
  local REPO_BRANCH=$4
  local REPO_DIR=$5
  local IS_PUBLIC=$6

  # Modify Nginx configuration file and copy it to Nginx conf directory
  nginx_conf=../conf/nginx.conf
  sed -i "s@YNH_WWW_PATH@${YNH_PATH%/}@g" $nginx_conf
  sed -i "s@YNH_WWW_ALIAS@$DESTDIR$REPO_DIR@g" $nginx_conf
  sudo cp $nginx_conf /etc/nginx/conf.d/$DOMAIN.d/$app.conf

  # TODO find a way to let user edit the hook and not overwrite it
  # Add post receive hook to the gogs repo
  sed -i "s@YNH_WWW_ALIAS@$DESTDIR/@g" "../conf/post-receive"
  sed -i "s@YNH_REPO_PATH@$REPO_PATH/@g" "../conf/post-receive"
  sed -i "s@YNH_GIT_BRANCH@$REPO_BRANCH@g" "../conf/post-receive"
  sudo cp "../conf/post-receive" $REPO_PATH"/hooks/post-receive"
  sudo chmod +x $REPO_PATH"/hooks/post-receive"
  sudo chown -R gogs:gogs $REPO_PATH

  # If app is public, add url to SSOWat conf as skipped_uris
  if [[ $IS_PUBLIC -eq 1 ]]; then
    # unprotected_uris allows SSO credentials to be passed anyway.
    ynh_app_setting_set "$app" unprotected_uris "/"
  fi

  # Reload services
  sudo systemctl reload nginx.service


}
