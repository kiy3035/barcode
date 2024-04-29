#!/usr/bin/env bash

ABSPATH=$(readlink -f $0) # 절대경로
ABSDIR=$(dirname $ABSPATH) # 현재 stop.sh가 속해있는 경로를 찾는다.
. /home/ubuntu/source/script/profile.sh # 자바로 보면 일종의 import 구문, stop.sh에서도 profile.sh의 여러 function을 사용 가능

# 실행 제일 오래된 pid를 찾음 특정 PID가 사용 중인 포트 찾기
OLD_RUN_PID=$(ps -eo pid,lstart,etime,cmd | awk '/java -jar -Dspring.profiles.active/ && !/awk/ {print $1, $2}' | sort -k3,3 | awk '{print $1}' | head -n 1)

echo "> $OLD_RUN_PID 에서 구동중인 애플리케이션 pid 확인"

# 현재 구동중인 애플리케이션이 없는지 확인
if [ -z ${OLD_RUN_PID} ]; then
  echo "> 현재 구동중인 애플리케이션이 없으므로 종료하지 않습니다."
else
  # 실행 중인 애플리케이션이 2개 이상일 때만 kill 실행
  COUNT=$(ps -ef | grep 'java -jar -Dspring.profiles.active' | grep -v grep | wc -l)
  if [ ${COUNT} -ge 2 ]; then
    # 3분(180초) 동안 기다림 이미 서비스는 되고 있어서 기존 트랜잭션을 처리되기를 기다리고 있음.
    #홈페이지는 필요없어서 대기시간 제외 시킴 일반 서비스는 필요함.
    #echo "> 3분(180초) 동안 대기합니다."
    #sleep 180
    
    echo "> 실행 중인 애플리케이션이 2개 이상입니다. kill을 실행합니다."
    echo "> kill -15 $OLD_RUN_PID"
    kill -15 ${OLD_RUN_PID}
  else
    echo "> 실행 중인 애플리케이션이 1개 뿐이므로 종료하지 않습니다."
  fi
fi
