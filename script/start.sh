#!/usr/bin/env bash

# 배포할 신규 버전 프로젝트를 stop.sh로 종료한 profile로 실행
ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)
. /home/ubuntu/source/script/profile.sh # 해당 코드로 profile.sh 내의 함수 사용

REPOSITORY=/home/ubuntu/source
JAVA_OPT=" -Xms64m -Xmx512m -XX:MaxMetaspaceSize=512m -Dfile.encoding=UTF-8"

#기본은 dev1
IDLE_PROFILE=dev1

echo ">>> Build 파일 복사"
echo ">>> cp $REPOSITORY/build/libs/*.jar $REPOSITORY/"

cp $REPOSITORY/build/libs/*.jar $REPOSITORY/
echo ">>> 새 어플리케이션 배포"
JAR_NAME=$(ls -tr $REPOSITORY/*.jar | tail -n 1)    # jar 이름 꺼내오기

echo ">>> JAR Name: $JAR_NAME"
echo ">>> $JAR_NAME 에 실행 권한 추가"
chmod +x $JAR_NAME

echo ">>> $JAR_NAME 실행"

RUNNING_COUNT=$(running_pid_count)

echo ">>> $RUNNING_COUNT 개가 실행 중에 있습니다."

# RUNNING_COUNT가 0보다 크면 IDLE_PROFILE에 find_idle_profile 실행 결과 할당
if [ $((RUNNING_COUNT)) -gt 0 ]; then
  IDLE_PROFILE=$(find_idle_profile)
fi

# 위에서 보았던 것처럼 $IDLE_PROFILE에는 set1 or set2가 반환되는데
# 반환되는 properties를 실행한다는 뜻.
echo ">>> $JAR_NAME 를 profile=$IDLE_PROFILE 로 실행합니다."

nohup java -jar -Dspring.profiles.active=$IDLE_PROFILE $JAVA_OPT $JAR_NAME > $REPOSITORY/nohup.out 2>&1 &