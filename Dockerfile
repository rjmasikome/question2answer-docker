FROM php:5.6-apache
MAINTAINER Mats Löfgren <mats.lofgren@matzor.eu>
MAINTAINER Rian Josua Masikome <rj@masiko.me>

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
    git libfreetype6-dev libpng12-dev libjpeg-dev zlib1g unzip wget && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install mysqli mbstring && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ &&\
    docker-php-ext-install gd calendar

ENV Q2A_VERSION 1.7.3
ENV Q2A_FILE_NAME question2answer-${Q2A_VERSION}.zip
ENV Q2A_DOWNLOAD_URL https://github.com/q2a/question2answer/releases/download/v${Q2A_VERSION}/${Q2A_FILE_NAME}

RUN mkdir -p /var/www && \
    rm -rf /var/www/html && \
    cd /var/www && pwd && \
    wget ${Q2A_DOWNLOAD_URL} && \
    unzip /var/www/${Q2A_FILE_NAME} && \
    mv /var/www/question2answer-${Q2A_VERSION} /var/www/html && \
    rm -f /var/www/${Q2A_FILE_NAME}

ADD q2a-install-plugin /usr/local/bin/q2a-install-plugin

# Adding some other plugins
RUN /usr/local/bin/q2a-install-plugin NoahY/q2a-badges && \
    /usr/local/bin/q2a-install-plugin nakov/q2a-plugin-open-questions && \
    /usr/local/bin/q2a-install-plugin q2a-projects/q2a-tag-descriptions && \
    /usr/local/bin/q2a-install-plugin arjunsuresh/categorydescription && \
    /usr/local/bin/q2a-install-plugin arjunsuresh/tag-search

# Adding Donut Theme
RUN git clone https://github.com/amiyasahu/Donut.git && \
    cp -r Donut/qa-plugin/Donut-admin /var/www/html/qa-plugin/ && \
    cp -r Donut/qa-theme/Donut-theme /var/www/html/qa-theme/ && \
    rm -rf Donut

ADD entrypoint.sh /entrypoint.sh
RUN chown root:root /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
