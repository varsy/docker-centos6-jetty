#!/bin/sh

trap "/sbin/service jetty stop" SIGINT SIGTERM SIGHUP

/sbin/service jetty console &

wait

