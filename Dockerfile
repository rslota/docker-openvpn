FROM lawtancool/docker-openvpn-xor

ADD ovpn_run_simple.sh .

# Management interface
EXPOSE 2080/tcp

CMD [ "ovpn_run_simple.sh" ]