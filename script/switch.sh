#!/usr/bin/env bash

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
. /home/ubuntu/source/script/profile.sh

#서버의 패스워드 없이 nginx를 수정하기 위한 /etc/sudoers를 수정필요.
function switch_proxy() {
    IDLE_PORT=$(find_idle_port)

    echo "> 전환할 Port: $IDLE_PORT"
    echo "> Port 전환"
    # 하나의 문장을 만들어 파이프라인(|)으로 넘겨 주기 위해 echo를 사용. tee 는 앞의 문장을 읽어 해당 경로의 파일에 저장.
    echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/conf.d/service-url.inc

    echo "> 엔진엑스 Reload"
    # restart와 달리 끊김 없이 다시 불러온다. (중요한 설정을 반영해야한다면 restart 사용)
    # 여기선 외부의 설정 파일인 service-url을 다시 불러오기 때문에 reload로 가능
    sudo service nginx reload
}