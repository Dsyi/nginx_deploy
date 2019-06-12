#!/bin/bash

CA_DIR=/usr/local/nginx/conf/cert
VHOST_DIR=/usr/local/nginx/conf/vhost
CONF_DIR=/usr/local/nginx/conf/

echo "You have 20s for making sure that files: 1_liveapi.cn_bundle.crt、2_liveapi.cn.key、session_ticket.key exist in /opt/nginx_deploy directory!"
echo "Ctrl + c for exit."
sleep 20

id www &>/dev/null
if [ $? -ne 0 ];then
    useradd -M -s /sbin/nologin www
fi

wget https://www.openssl.org/source/openssl-1.1.1c.tar.gz       
wget http://nginx.org/download/nginx-1.16.0.tar.gz       
tar fx openssl-1.1.1c.tar.gz      
tar fx nginx-1.16.0.tar.gz      
cd nginx-1.16.0/       
yum install gcc zlib-devel pcre-devel lsof -y    
./configure --prefix=/usr/local/nginx --with-openssl=../openssl-1.1.1c --with-pcre --with-stream --with-stream_ssl_module --with-http_ssl_module --with-http_v2_module --with-threads
make && make install     
#scp root@10.200.1.245:/usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/      
#scp -r root@10.200.1.245:/usr/local/nginx/conf/cert/ /usr/local/nginx/conf/
     
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


cp nginx.conf ${CONF_DIR}
/usr/local/nginx/sbin/nginx -t       
[ $? -eq 0 ] && echo "Deploy Successfully" || echo -e "\n\n\nsbin/nginx -t Error!"

/usr/local/nginx/sbin/nginx 
[ $? -eq 0 ] && echo "Start OK" || echo "Start Error!" 
