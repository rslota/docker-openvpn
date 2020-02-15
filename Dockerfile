FROM kylemanna/openvpn

ADD ovpn_run_simple.sh .

# Management interface
EXPOSE 2080/tcp

CMD [ "ovpn_run_simple.sh" ]