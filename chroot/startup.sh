#!/bin/bash

upsert_toor()
{
    TF=$1
    if [ ! -e /home/toor/${TF} ];then
        DN="/home/toor/$(dirname ${TF})"
        if [ ! -d ${DN} ];then
            mkdir -p ${DN}
        fi
        cp -rf /usr/local/toor/${TF} /home/toor/${TF}
        chown -R toor:toor ${DN}
    fi
}

sh /usr/local/bin/docker-entrypoint.sh

upsert_toor .bashrc
upsert_toor .bash_profile
upsert_toor .profile
upsert_toor .i18n
upsert_toor .tmux.conf
upsert_toor .config
upsert_toor .cache
upsert_toor .uim.d
upsert_toor .pip
upsert_toor .vimrc
upsert_toor .gitignore


# mkdir -p /var/run/sshd
# chown -R root:root /root
# mkdir -p /root/.config/pcmanfm/LXDE/
# cp /usr/share/doro-lxde-wallpapers/desktop-items-0.conf /root/.config/pcmanfm/LXDE/

if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/conf.d/supervisord.conf
    export VNC_PASSWORD=
fi

cd /usr/lib/web && ./run.py > /var/log/web.log 2>&1 &
# mkdir -p /run/nginx
# nginx -c /etc/nginx/nginx.conf

exec /bin/tini -- /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
