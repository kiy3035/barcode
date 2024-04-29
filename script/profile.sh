#!/bin/sh

# 쉬고 있는 profile 찾기: dev1이 사용중이면 dev2가 쉬고 있고, 반대면 dev1이 쉬고 있음
function find_idle_profile()
{   # 현재 엔진엑스(포트)가 바라보고 있는 스프링부트가 정상적으로 수행 중인지 확인.
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/open/profile)

    if [ ${RESPONSE_CODE} -ge 400 ] # 400 보다 크면 (즉, 40x/50x 에러 모두 포함)
    then # 오류가 발생하면 real2를 현재 profile로 사용
        CURRENT_PROFILE=dev2
    else
        CURRENT_PROFILE=$(curl -s http://localhost:8080/open/profile)
    fi

    if [ ${CURRENT_PROFILE} == dev1 ]
    then # IDLE_PROFILE 은 엔진엑스와 연결되지 않은 프로필 , 스프링 부트 프로젝트를 이 프로필로 연결
      IDLE_PROFILE=dev2
    else
      IDLE_PROFILE=dev1
    fi

# bash는 return value가 안되니 *제일 마지막줄에 echo로 해서 결과 출력*후, 클라이언트에서 값을 사용한다
    echo "${IDLE_PROFILE}"
}

# 쉬고 있는 profile의 port 찾기
function find_idle_port()
{
    IDLE_PROFILE=$(find_idle_profile)
		
    if [ ${IDLE_PROFILE} == dev1 ]
    then
      echo "10001"
    else
      echo "10002"
    fi
}

function find_idle_port_old_port()
{
	# 제일 늦게 실행되는 pid를 찾음 특정 PID가 사용 중인 포트 찾기
	PID=$(ps -eo pid,lstart,etime,cmd | awk '/java -jar -Dspring.profiles.active/ && !/awk/ {print $1}' | sort -k3,3 | head -n 1)
	
	# lsof 명령어로 해당 PID가 사용 중인 포트 찾기
	PORTS=$(lsof -i -P -n -a -p $PID | awk 'NR>1 {print $9}' | awk -F ":" '{print $NF}' | sort -u)
	
	echo "$PORTS"
}

#현재 실행 중인 프로세스 개수를 찾는다.
function running_pid_count(){

        UP_COUNT=$(ps -ef | grep 'Dspring.profiles.active=dev' | grep -v grep | wc -l)
        UP_COUNT=$((UP_COUNT))
        echo "$UP_COUNT"
}
