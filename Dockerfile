FROM debian:buster

RUN apt-get update; \
	apt-get -y install nginx \
		vim \
        	wget \
        	unzip \
        	openssl \
		wordpress \
		php php-fpm php-cgi php-net-socket \
		default-mysql-server php-mysql \
	&& rm -rf /var/lib/apt/lists/*;

COPY srcs/default.tmpl /etc/nginx/sites-available/default.tmpl

#ssl
RUN mkdir /etc/nginx/ssl; \
	openssl genrsa -out /etc/nginx/ssl/server.key 2048; \
	openssl req -new -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr -subj "/C=JP/ST=Tokyo/L=Minato-ku/O=DMM/OU=42Tokyo/CN=localhost"; \
	openssl x509 -in /etc/nginx/ssl/server.csr -days 3650 -req -signkey /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.crt;

EXPOSE 80 443

#wordpress
RUN wget https://ja.wordpress.org/latest-ja.tar.gz; \
	tar xzf latest-ja.tar.gz -C /var/www/html; \
	rm latest-ja.tar.gz;
COPY srcs/wp-config.php /var/www/html/wordpress

#phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.0/phpMyAdmin-5.0.0-all-languages.zip; \
	unzip phpMyAdmin-5.0.0-all-languages.zip; \
	mv phpMyAdmin-5.0.0-all-languages /var/www/html/phpmyadmin;

#mysql
RUN service mysql start; \
	mysql -e "CREATE DATABASE wordpress_db;"; \
	mysql -e "GRANT ALL PRIVILEGES ON wordpress_db.* TO 'username'@'localhost' identified by 'password';"; \
	mysql -e "FLUSH PRIVILEGES;";

#entrykit
RUN wget https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz\
	&& tar -xvzf entrykit_0.4.0_Linux_x86_64.tgz \
	&& rm entrykit_0.4.0_Linux_x86_64.tgz \
	&& mv entrykit /bin/entrykit \
	&& entrykit --symlink

CMD service nginx start; \
	service php7.3-fpm start; \
	service mysql start; \
	tail -f /dev/null;

ENTRYPOINT ["render", "/etc/nginx/sites-available/default", "--"]
