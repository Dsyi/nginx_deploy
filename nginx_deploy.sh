#!/bin/bash

CA_DIR=/usr/local/nginx/conf/cert
VHOST_DIR=/usr/local/nginx/conf/vhost
CONF_DIR=/usr/local/nginx/conf/
WORK_DIR=/opt/nginx_deploy

echo "You have 20s for making sure that files: 1_liveapi.cn_bundle.crt、2_liveapi.cn.key、session_ticket.key exist in /opt/nginx_deploy directory!"
echo "Ctrl + c for exit."
sleep 20

echo "Creating account: www" ;sleep 3
id www &>/dev/null
if [ $? -ne 0 ];then
    useradd -M -s /sbin/nologin www
fi

echo -e "\n\n\nInstalling : tar, dependency, run configure script, make, make install..." ;sleep 3
tar fx openssl-1.1.1c.tar.gz      
tar fx nginx-1.16.0.tar.gz      
cd nginx-1.16.0/       
yum install gcc zlib-devel pcre-devel lsof -y    
./configure --prefix=/usr/local/nginx --with-openssl=../openssl-1.1.1c --with-pcre --with-stream --with-stream_ssl_module --with-http_ssl_module --with-http_v2_module --with-threads
make && make install     

cd $WORK_DIR
echo -e "\n\n\nCoping liveapi.cn_bundle.crt, liveapi.cn.key, session_ticket.key...";sleep 3
if [ -d ${CA_DIR} ];then
    cp ${CA_DIR} /tmp 
    rm -fr ${CA_DIR}/* 
    cp 1_liveapi.cn_bundle.crt  2_liveapi.cn.key  session_ticket.key ${CA_DIR} 
else
    mkdir -p ${CA_DIR}
    cp 1_liveapi.cn_bundle.crt  2_liveapi.cn.key  session_ticket.key ${CA_DIR}
fi

if [ -d ${VHOST_DIR} ];then
    cp  liveapi.cn.conf ${VHOST_DIR}
else
    mkdir -p ${VHOST_DIR}
    cp  liveapi.cn.conf ${VHOST_DIR}
fi

cp $WORK_DIR/nginx.conf ${CONF_DIR}

[ -f ${CA_DIR}/1_liveapi.cn_bundle.crt ] && echo -e "\n\n\n1_liveapi.cn_bundle.crt Copied Successful." || echo -e "\n\n\n1_liveapi.cn_bundle.crt Copied Failed"
[ -f ${CA_DIR}/2_liveapi.cn.key ] && echo -e "\n\n\n2_liveapi.cn.key Copied Successful." || echo -e "\n\n\n2_liveapi.cn.key Copied Failed"
[ -f ${CA_DIR}/session_ticket.key ] && echo -e "\n\n\nsession_ticket.key Copied Successful." || echo -e "\n\n\nsession_ticket.key Copied Failed"
[ -f ${VHOST_DIR}/liveapi.cn.conf ] && echo -e "\n\n\nliveapi.cn.conf Copied Successful." || echo -e "\n\n\nliveapi.cn.conf Copied Failed"


echo
echo 
echo
/usr/local/nginx/sbin/nginx -t       
[ $? -eq 0 ] && echo "Deploy Successfully" || echo -e "\n\n\nsbin/nginx -t Error!"

echo
echo
/usr/local/nginx/sbin/nginx 
[ $? -eq 0 ] && echo "Start OK" || echo "Start Error!" 
