#!/bin/sh

trap "/sbin/service jetty stop ; exit 0" SIGINT SIGTERM SIGHUP

/sbin/service jetty console &

wait

