#!/bin/sh

# Nginx와 연결되지 않은 포트로 스프링 부트가 잘 수행되었는지 체크
# 현재 스크립트 파일의 절대 경로를 찾아서 ABSPATH 변수에 저장합니다. readlink -f $0는 스크립트 파일의 심볼릭 링크를 따라가며 절대 경로를 찾아줍니다.
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
. /home/ubuntu/source/script/profile.sh
. /home/ubuntu/source/script/switch.sh

IDLE_PORT=$(find_idle_port)

echo "> Health Check Start!"
echo "> IDLE_PORT: $IDLE_PORT"
echo "> curl -s http://localhost:$IDLE_PORT/open/profile"
sleep 10

for RETRY_COUNT in {1..10}
do
  RESPONSE=$(curl -s http://localhost:${IDLE_PORT}/open/profile)
  echo "> http://localhost:${IDLE_PORT}/profile"
  UP_COUNT=$(echo ${RESPONSE} | grep -o 'dev' | wc -l)
  echo "upcount > ${UP_COUNT}"
  
  if [ ${UP_COUNT} -ge 1 ]
  then # $up_count >= 2 ("dev" 문자열이 있는지 검증)
      echo "> Health check 성공"
      switch_proxy # 잘 떳다면, switch.sh의 switch_proxy로 Nginx 프록시 설정을 변경
      break
  else
      echo "> Health check의 응답을 알 수 없거나 혹은 실행 상태가 아닙니다."
      echo "> Health check: ${RESPONSE}"
  fi

  if [ ${RETRY_COUNT} -eq 10 ]
  then
    echo "> Health check 실패. "
    echo "> 엔진엑스에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..."
  sleep 10
done