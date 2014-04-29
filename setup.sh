#!/bin/sh
HOST=wpvm.lvh.me
vagrant ssh-config --host $HOST >>$HOME/.ssh/config
ssh $HOST sudo aptitude update
ssh $HOST sudo aptitude upgrade -y
knife solo prepare $HOST
knife solo cook $HOST
