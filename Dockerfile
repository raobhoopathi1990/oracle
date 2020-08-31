FROM oraclelinux
MAINTAINER propan@gmail.com

#Prereq
RUN yum -y install oracle-rdbms-server-12cR1-preinstall.x86_64 && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y rlwrap && \
    yum clean all && \ 
    rm -rf /var/lib/{cache,log} /var/log/lastlog

#sudo utility (blamed more efficent for docker than ordinary sudo)
RUN curl -o /usr/local/bin/gosu -SL 'https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64' && chmod +x /usr/local/bin/gosu


RUN echo "oracle:oracle" | chpasswd \
 && echo "oracle   soft   nofile    1024" >> /etc/security/limits.conf \
 && echo "oracle   hard   nofile    65536" >> /etc/security/limits.conf \
 && echo "oracle   soft   nproc    2047" >> /etc/security/limits.conf \
 && echo "oracle   hard   nproc    16384" >> /etc/security/limits.conf \
 && echo "oracle   soft   stack    10240" >> /etc/security/limits.conf \
 && echo "oracle   hard   stack    32768" >> /etc/security/limits.conf 


ENV ORACLE_BASE=/u01/app/oracle
ENV ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/dbhome_1
ENV PATH=$ORACLE_HOME/bin:$PATH
ENV ORACLE_HOME_LISTNER=$ORACLE_HOME
ENV ORACLE_SID=orcl
RUN mkdir -p $ORACLE_BASE && chown -R oracle:oinstall $ORACLE_BASE && \
    chmod -R 775 $ORACLE_BASE && \
    mkdir -p /app/oraInventory && \
    chown -R oracle:oinstall /app/oraInventory && \
    chmod -R 775 /app/oraInventory && \
    chmod -R 775 /u01 && \
    chown -R oracle:oinstall /u01 && \
    mkdir /oracle.init.d && \
    chown -R oracle:oinstall /oracle.init.d && \
    mkdir -p /u01/app/oracle-product && chown oracle:oinstall /u01/app/oracle-product && \
    ln -s /u01/app/oracle-product $ORACLE_BASE/product

ENV INIT_MEM_PST 40
ENV SW_ONLY false
ENV TERM dumb

ADD entrypoint.sh /entrypoint.sh

EXPOSE 1521
EXPOSE 8080
EXPOSE 5500

VOLUME ["/u01/app/oracle"]

ENTRYPOINT ["/entrypoint.sh"]
