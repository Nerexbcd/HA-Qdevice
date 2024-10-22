#!/usr/bin/with-contenv bashio

if [ -n "$(bashio::config 'root_password')" ]; then
  echo "root:$(bashio::config 'root_password')" | chpasswd
else
  echo "root:pveqdevice" | chpasswd
fi

echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

if [ -n "$TZ" ]; then
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

exec /usr/sbin/sshd -D