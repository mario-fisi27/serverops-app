#!/bin/bash

echo "=== ServerOps Healthcheck ==="
echo

echo "Apache:"
systemctl is-active httpd

echo
echo "Tomcat:"
systemctl is-active tomcat

echo
echo "MariaDB:"
systemctl is-active mariadb

echo
echo "Tinyproxy:"
systemctl is-active tinyproxy

echo
echo "Ports:"
ss -tulpen | grep -E ':80|:443|:8080|:8888'
