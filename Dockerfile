FROM ubuntu
MAINTAINER nmason <nick.mason@arrowuniforms.co.nz>


# SET TIMEZONE TO MAKE DPKG WORK CORRECTLY IN NON INTERACTIVE MODE

RUN echo "Pacific/Auckland" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata

# SETUP OSX FRIENDLY USERS / PERMISSIONS

ENV USER_ID 1000
ENV USER_GID 50

RUN useradd -ms /bin/bash -r mysql -u ${USER_ID} && usermod -G staff mysql

RUN groupmod -g $(($USER_GID + 10000)) $(getent group $USER_GID | cut -d: -f1)
RUN groupmod -g ${USER_GID} staff



RUN adduser mysql sudo 
RUN mkdir /home/mysql/.ssh && chown -R mysql:mysql /home/mysql/.ssh && chmod 775 -R /home/mysql/.ssh



# ----- SSH CONFIG -----

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

#RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin no/' /etc/ssh/sshd_config

# -----  MYSQL -----



RUN apt-get -y install mysql-server-5.6 pwgen zip unzip
RUN sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/mysql/my.cnf
RUN sed -i "s/user.*/user = mysql/" /etc/mysql/my.cnf
RUN sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN sed -i "s/user.*/user = mysql/" /etc/mysql/my.cnf

# ----- SUPERVISOR -----

RUN apt-get install -y supervisor
RUN mkdir -p /var/log/supervisor

ADD ./supervisord.conf /etc/supervisor/supervisord.conf


# ----- FINALIZE SETUP -----
ADD ./startup.sh /startup.sh
RUN chmod 755 /*.sh

EXPOSE 3306
EXPOSE 22

VOLUME ["/var/lib/mysql", "/etc/my.cnf"]

# COPY MYSQL BASE

ENV MYSQL_PASS:-$(pwgen -s 12 1)

RUN locale-gen en_NZ.UTF-8

CMD ["/startup.sh"]