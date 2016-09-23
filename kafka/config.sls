# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "kafka/map.jinja" import kafka with context %}

kafka-config:
  file.managed:
    - name: {{ kafka.config }}
    - source: salt://kafka/files/conf/server.properties
    - template: jinja
    - mode: 644
    - user: root
    - group: root

kafka-log4j-config:
  file.managed:
    - name: {{ kafka.log4j_config }}
    - source: salt://kafka/files/conf/log4j.properties
    - template: jinja
    - mode: 644
    - user: root
    - group: root
