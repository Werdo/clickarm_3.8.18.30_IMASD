cmd_drivers/net/wireless/ti/wl18xx/built-in.o :=  arm-linux-gnueabihf-ld -EL    -r -o drivers/net/wireless/ti/wl18xx/built-in.o drivers/net/wireless/ti/wl18xx/wl18xx.o ; scripts/mod/modpost drivers/net/wireless/ti/wl18xx/built-in.o