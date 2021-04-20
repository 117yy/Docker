# Docker
web server : nginx  
container OS : debian
>- You can go localhost:(port number)/wordpress.
>- You can go localhost:(port number)/phpmyadmin too and see database of wordpress there. Login phpmyadmin with 'username' for username and 'password' for password.
>> You can change database setting such as username, password, database name by editing srcs/wp-config.php.

# Useage
in root of this repo,
>docker build -t (image name) .  
>docker run -p (port number):80 -p 443:443 (image name)  
* Autoindex is activated by default. If you don't want to be seen inside of container, I recomend to deactivate autoindex:
>docker run -p (port number):80 -p 443:443 (image name) -e AUTOINDEX=off
