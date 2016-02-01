FROM sergeyzh/centos6-java:jdk8
MAINTAINER Andrey Sizov, andrey.sizov@jetbrains.com

RUN /usr/sbin/useradd jetty

ENV HOME /home/jetty

RUN wget -O /home/jetty/jetty.tar.gz "http://eclipse.org/downloads/download.php?file=/jetty/8.1.16.v20140903/dist/jetty-distribution-8.1.16.v20140903.tar.gz&r=1"
RUN cd /home/jetty ; tar zxf /home/jetty/jetty.tar.gz ; mv jetty-distribution-8.1.16.v20140903 jetty-current

RUN wget -O /home/jetty/wrapper.tar.gz "http://wrapper.tanukisoftware.com/download/3.5.25/wrapper-linux-x86-64-3.5.25.tar.gz"
RUN cd /home/jetty ; tar zxf /home/jetty/wrapper.tar.gz ; cp -rp wrapper-linux-*/* /home/jetty/jetty-current/ 

RUN cp -p /home/jetty/jetty-current/src/bin/sh.script.in /home/jetty/jetty-current/bin/jetty

RUN sed -i '/# Application/a export JAVA_HOME=\/usr\/java64\/current\nexport JETTY_HOME=\/home\/jetty\/jetty-current\nexport JETTY_PORT=8081\n' /home/jetty/jetty-current/bin/jetty 
RUN sed -i "s/@app.name@/jetty/g" /home/jetty/jetty-current/bin/jetty 
RUN sed -i "s/@app.long.name@/jetty/g" /home/jetty/jetty-current/bin/jetty 
RUN sed -i "s/^WRAPPER_CMD=.*/WRAPPER_CMD=\"wrapper\"/" /home/jetty/jetty-current/bin/jetty 
RUN sed -i "s/^WRAPPER_CONF=.*/WRAPPER_CONF=\"\.\.\/conf\/wrapper.conf\"/" /home/jetty/jetty-current/bin/jetty 

RUN sed -i '/org.eclipse.jetty.server.nio.SelectChannelConnector/a <Set name="requestHeaderSize"><Property name="jetty\.request\.header\.size" default="8192" \/><\/Set>\n<Set name="responseHeaderSize"><Property name="jetty\.response\.header\.size" default="8192" \/><\/Set>' /home/jetty/jetty-current/etc/jetty.xml

ADD wrapper.conf /home/jetty/jetty-current/conf/wrapper.conf

RUN touch /home/jetty/jetty-current/conf/wrapper-additional.conf

RUN ln -s /home/jetty/jetty-current/bin/jetty /etc/init.d/ ; chmod +x /etc/init.d/jetty
RUN rm -f /home/jetty/jetty-current/webapps/test.war ; rm -f /home/jetty/jetty-current/contexts/*.xml

RUN chown -R jetty:jetty /home/jetty
RUN chmod -R a+rwX /home/jetty

RUN echo "STOP.PORT=8990" >> /home/jetty/jetty-current/start.ini
RUN echo "STOP.KEY=mysecretkey" >> /home/jetty/jetty-current/start.ini

ADD run-jetty.sh /

# Start supervisord as a foreground process when running without a shell
CMD /run-jetty.sh

EXPOSE 8081
