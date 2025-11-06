FROM debian:bookworm-slim

LABEL author="kikozilla@gmail.com"
LABEL description="Yandex Disk client container"

ENV DATA="" \
    TOKEN_FILE="" \
    INTERVAL="60" \
    EXCLUDE="" \
    OPTIONS=""

COPY entrypoint.sh /

RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates gnupg \
    && echo "deb http://repo.yandex.ru/yandex-disk/deb/ stable main" \
        > /etc/apt/sources.list.d/yandex.list \
    && wget http://repo.yandex.ru/yandex-disk/YANDEX-DISK-KEY.GPG -qO- | apt-key add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends yandex-disk \
    && chmod +x /entrypoint.sh \
    && mkdir /yandex && chmod 777 /yandex \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]