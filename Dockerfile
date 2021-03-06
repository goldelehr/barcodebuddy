FROM lsiobase/nginx:3.11

#Build example: docker build --no-cache --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` --build-arg VERSION="v1.4.0.0" -t forceu/barcodebuddy-docker .

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BBUDDY_RELEASE
LABEL build_version="BarcodeBuddy ${VERSION} Build ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"



RUN \
  echo "**** Installing runtime packages ****" && \
  apk add --no-cache \
  curl \
  evtest \
  php7 \
  php7-curl \
  php7-openssl \
  php7-pdo \
  php7-pdo_sqlite \
  php7-sqlite3 \
  php7-sockets \
  screen \
  sudo
RUN \
  echo "**** Installing BarcodeBuddy ****" && \
  mkdir -p /app/bbuddy && \
  git clone https://github.com/Forceu/barcodebuddy.git /app/bbuddy/ &&  \
  rm -r /app/bbuddy/.git/ && \
  sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php && \
  echo "Set disable_coredump false" > /etc/sudo.conf && \
  sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh && \
  sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php7/php-fpm.d/www.conf && \
  sed -i 's/WWW_USER=.*/WWW_USER="abc"/g' /app/bbuddy/example/grabInput.sh && \
  sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/docker/parseEnv.sh && \
  sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh
#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

RUN \
  echo "**** Cleanup ****" && \
  rm -rf \
  /root/.cache \
  /tmp/*

# copy local files
#COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config