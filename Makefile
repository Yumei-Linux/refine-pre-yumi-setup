PREFIX=/usr

install: main.sh
	chmod +x ./main.sh
	install -Dvm755 ./main.sh ${PREFIX}/bin/refine-pre-yumi-setup
