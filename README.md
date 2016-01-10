# osx-mysql
Docker MySQL Server with friendly permissions for Mac OS X combined with Docker Toolbox.

### Overview
Docker image that is friendly with Mac OS X volumes where standard images may refuse mysql from accessing volume causing a fatal error.

- Based on Ubuntu Trusty
- MySQL 5.6
- SSH enabled

### Basic Usage
To get started you can simply run out-of-the-box.  A random 'root' password and 'admin' password will be generated and dispalyed in the console.  You can set these passwords using enviroment varables.

```
docker run -v /path/to/local/mysql/dir:/var/lib/mysql -p 22:22 -p 3306:3306 nmason/osx-mysql
```

The MySql user 'root' only allows localhost connections.  The user 'admin' however is configured to allow both localhost and outside connections.

### SSH Access
SSH is enabled allowing SSH tunnelling to mysql.  Root access is disabled, however the user 'mysql' can be used and a random password is displayed in the console when the container starts up (Also can be setup by specifying ```SSH_PASS``` as enviroment option )

```
ssh -p {port} -L 3306:3306 mysql@{ip_address}
```

### Enviroment Varables

Several enviroment varables are availble enabling you to set passwords for the mysql database and ssh user.

```
docker run -d -e MYSQL_ROOT_PASS=something nmason/osx-mysql
```


- ```MYSQL_ROOT_PASS``` Sets the password for user 'root' when initilizing mysql database for first time.
- ```MYSQL_ADMIN_PASS``` Sets the password for user 'admin' when initilizing mysql database for first time.
- ```SSH_PASS``` Sets the password for ssh user 'mysql' on startup.

Set these variables using the ```-e``` flag when specifing your docker configiuration.

#### Credits

When creating this docker file I adopted concepts from [dgraziotin/osx-docker-mysql](https://github.com/dgraziotin/osx-docker-mysql)


