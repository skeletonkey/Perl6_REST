FROM rakudo-star:2018.01
MAINTAINER Erik Tank <erik.tank@ticketmaster.com>


WORKDIR /code

RUN apt-get update; apt-get -y install mysql-server;
#https://stackoverflow.com/questions/50175106/installation-requirements-for-mysql-with-dbiish-on-rakudo-star-docker-image
RUN ln -s /usr/lib/x86_64-linux-gnu/libmariadbclient.so.18 /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18;

RUN zef install bailador Data::Dump

RUN echo 'alias ll="ls -al"' >> ~/.bashrc;
RUN echo 'alias start="clear; bailador easy /code/Idea-Lab/bin/app.pl6"' >> ~/.bashrc;
RUN echo 'alias start_mysql="/etc/init.d/mysql start;"' >> ~/.bashrc;

CMD /etc/init.d/mysql start; bailador easy /code/Idea-Lab/bin/app.pl6

# mysql -u coc -pcoc123! coc
# explorer run -p 3123:3123 -v $(pwd)/mysql:/var/lib/mysql
