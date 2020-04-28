FROM lsiobase/nginx:3.11

#Build example: docker build --no-cache --pull --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` -t forceu/barcodebuddy-docker -f Dockerfile.dev .

# set version label
ARG BUILD_DATE
LABEL build_version="BarcodeBuddy DevBuild Build-date: ${BUILD_DATE}"
LABEL maintainer="Marc Ole Bulling"


RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies git && \
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
  sudo && \
  echo "**** Installing BarcodeBuddy ****" && \
  mkdir -p /app/bbuddy/ && \
  git clone https://github.com/goldelehr/barcodebuddy.git /app/bbuddy/ &&  \
  rm -r /app/bbuddy/.git/ && \
  sed -i 's/[[:blank:]]*const[[:blank:]]*IS_DOCKER[[:blank:]]*=[[:blank:]]*false;/const IS_DOCKER = true;/g' /app/bbuddy/config-dist.php && \
  echo "Set disable_coredump false" > /etc/sudo.conf && \
  sed -i 's/SCRIPT_LOCATION=.*/SCRIPT_LOCATION="\/app\/bbuddy\/index.php"/g' /app/bbuddy/example/grabInput.sh && \
  sed -i 's/pm.max_children = 5/pm.max_children = 20/g' /etc/php7/php-fpm.d/www.conf && \
  sed -i 's/WWW_USER=.*/WWW_USER="abc"/g' /app/bbuddy/example/grabInput.sh && \
  sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/docker/parseEnv.sh && \
  sed -i 's/IS_DOCKER=.*/IS_DOCKER=true/g' /app/bbuddy/example/grabInput.sh && \
  echo "**** Cleanup ****" && \
  apk del --purge build-dependencies && \
  rm -rf /root/.cache /tmp/*

#Bug in sudo requires disable_coredump
#Max children need to be a higher value, otherwise websockets / SSE might not work properly

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config