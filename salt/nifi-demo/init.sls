# https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html
   
# download nifi and nifi-kit
# note: too large, for now we just reference the one in the shared folder

unzip-nifi:
    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: /srv/nifi-1.7.1/
        - source: /vagrant/downloads/nifi-1.7.1-bin.tar.gz
        - source_hash: 51dd598178992fa617cb28a8c77028b3
        - keep_source: True # default

unzip-nifi-toolkit:
    archive.extracted:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: /srv/
        - if_missing: /srv/nifi-toolkit-1.7.1
        - source: /vagrant/downloads/nifi-toolkit-1.7.1-bin.tar.gz
        - source_hash: 3247bb6194977da6dbf90d476289e0de
        - keep_source: True # default
        
{% set nifi_dir = "/srv/nifi-1.7.1" %}
{% set nifi_tk_dir = "/srv/nifi-toolkit-1.7.1" %}

# this creates a /etc/init.d/ init file
install-init-file:
    cmd.run:
        - cwd: {{ nifi_dir }}/bin/
        - name: ./nifi.sh install
        
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
