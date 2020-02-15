FROM lawtancool/docker-openvpn-xor

ADD ovpn_run_simple.sh /usr/local/bin/ovpn_run_simple
RUN chmod +x /usr/local/bin/ovpn_run_simple

# Management interface
EXPOSE 2080/tcp

CMD [ "ovpn_run_simple" ]