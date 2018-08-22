# https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html
   
# download nifi and nifi-kit
# note: too large, for now we just reference the one in the shared folder

# vagrant only
# guest:/root/downloads -> guest:/vagrant -> host:./builder/downloads
vagrant-root-downloads-link:
    cmd.run:
        - cwd: /root
        - name: rm -f downloads && ln -s /vagrant/downloads
        - onlyif:
            - test -d /vagrant

download-nifi:
    file.managed:
        - name: /root/downloads/nifi-1.7.1-bin.tar.gz
        - source: http://www-eu.apache.org/dist/nifi/1.7.1/nifi-1.7.1-bin.tar.gz
        - source_hash: 51dd598178992fa617cb28a8c77028b3
        - makedirs: True
        - replace: False
        - require:
            - vagrant-root-downloads-link

    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: /srv/nifi-1.7.1/
        - source: /root/downloads/nifi-1.7.1-bin.tar.gz
        - source_hash: 51dd598178992fa617cb28a8c77028b3
        - keep_source: True # default
        - require:
            - file: download-nifi

download-nifi-toolkit:
    file.managed:
        - name: /root/downloads/nifi-toolkit-1.7.1-bin.tar.gz
        - source: http://www-eu.apache.org/dist/nifi/1.7.1/nifi-toolkit-1.7.1-bin.tar.gz
        - source_hash: 3247bb6194977da6dbf90d476289e0de
        - makedirs: True
        - replace: False
        - require:
            - vagrant-root-downloads-link

    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: /srv/nifi-toolkit-1.7.1
        - source: /root/downloads/nifi-toolkit-1.7.1-bin.tar.gz
        - source_hash: 3247bb6194977da6dbf90d476289e0de
        - keep_source: True # default
        - require:
            - file: download-nifi-toolkit

{% set nifi_dir = "/srv/nifi-1.7.1" %}
{% set nifi_tk_dir = "/srv/nifi-toolkit-1.7.1" %}

# this creates a /etc/init.d/ init file
install-init-file:
    file.managed:
        - name: /lib/systemd/system/nifi.service
        - source: salt://nifi-demo/config/lib-systemd-system-nifi.service

nifi-config-properties:
    file.managed:
        - name: {{ nifi_dir }}/conf/nifi.properties
        - source: salt://nifi-demo/config/srv-nifi-conf-nifi.properties

nifi:
    # this can take a short while to come up
    service.running:
        # doesn't seem to be working, use "service nifi start" or "systemctl start nifi"
        # use "pgrep nifi" or "service nifi status" or "systemctl status nifi" to see if it's running
        - enable: True
        - watch:
            - nifi-config-properties

nifi-nginx-proxy:
    file.managed:
        - name: /etc/nginx/sites-enabled/nifi-demo.conf
        - source: salt://nifi-demo/config/etc-nginx-sites-enabled-nifi-demo.conf
        - template: jinja
        - watch_in:
            - service: nginx-server-service
