#!/bin/bash

#-----------------------------------------------------------------
# Prueba gpios para velo. Perpetrado por Arturo Sapiña. Octubre 2016
#-----------------------------------------------------------------

#-----------------INICIALIZAR TODO-------------------------------

PUERTO_GPS=/dev/ttySAC3
PUERTO_GPRS=/dev/ttySAC0
PUERTO_BT=/dev/ttySAC2

DS278=0x34
TOUCH=0x00
MPU9250=0x68 #0x0C?
MAX44005=0x00
TMP103=0x00
LPS25=0x00

touch "/home/odroid/action-log-$(date +%d-%m-%Y)"
ARCHIVO_LOG="/home/odroid/action-log-$(date +%d-%m-%Y)"

function inicializar_gpios
{
	#----------------GPRS--------------------
	echo 57 > /sys/class/gpio/export #!on/off
	echo out > /sys/class/gpio/gpio57/direction

	echo 62 > /sys/class/gpio/export #status
	echo in > /sys/class/gpio/gpio62/direction

	echo 51 > /sys/class/gpio/export #pwrkey
	echo out > /sys/class/gpio/gpio51/direction

	#----------------GPS--------------------
	echo 81 > /sys/class/gpio/export #on/off
	echo out > /sys/class/gpio/gpio81/direction

	echo 84 > /sys/class/gpio/export #status
	echo in > /sys/class/gpio/gpio84/direction

	echo 59 > /sys/class/gpio/export #reset
	echo out > /sys/class/gpio/gpio59/direction

	#---------------WLAN/BT--------------------
	echo 135 > /sys/class/gpio/export #wlan-enable
	echo out > /sys/class/gpio/gpio135/direction

	echo 128 > /sys/class/gpio/export #bt-enable
	echo in > /sys/class/gpio/gpio128/direction

	#-------------botones--------------------

	echo 111 > /sys/class/gpio/export #topleft
	echo in > /sys/class/gpio/gpio111/direction

	echo 78 > /sys/class/gpio/export #topright
	echo in > /sys/class/gpio/gpio78/direction

	echo 123 > /sys/class/gpio/export #botright
	echo in > /sys/class/gpio/gpio123/direction

	echo 132 > /sys/class/gpio/export #botleft
	echo in > /sys/class/gpio/gpio132/direction

	#---------------Max8814------------------

	echo 71 > /sys/class/gpio/export #!enable
	echo out > /sys/class/gpio/gpio71/direction
	echo 0 > /sys/class/gpio/gpio71/value # nivel bajo por defecto

	echo 70 > /sys/class/gpio/export #pow_ok
	echo in > /sys/class/gpio/gpio70/direction

	#----------------buzzer----------------

	echo 37 > /sys/class/soft_pwm/export
	echo 22000 > /sys/class/soft_pwm/pwm37/period

	#---------------Backlight--------------

	echo 39 > /sys/class/soft_pwm/export
	echo 1000 > /sys/class/soft_pwm/pwm39/period #checkear nueva GPIO

	#---------------otros-------------------
}



#--------------------TESTS--------------------

#GPRS
function test_gprs 
{
	echo ".........................probando GPRS....................."|tee -a $ARCHIVO_LOG
	echo 0 > /sys/class/gpio/gpio57/value
	echo 1 > /sys/class/gpio/gpio51/value
	sleep 2
	echo 0 > /sys/class/gpio/gpio51/value 
	if [ $(cat /sys/class/gpio/gpio62/value) -eq 1 ]; then
		echo " GPRS da señal"|tee -a $ARCHIVO_LOG
		gprs_vivo
	else
		echo " el GPRS no responde, reintento... "|tee -a $ARCHIVO_LOG
		echo 0 > /sys/class/gpio/gpio57/value
		echo 1 > /sys/class/gpio/gpio51/value
		sleep 2
		echo 0 > /sys/class/gpio/gpio51/value 
		if [ $(cat /sys/class/gpio/gpio62/value) -eq 1 ]; then
			echo " GPRS da señal"|tee -a $ARCHIVO_LOG
			gprs_vivo
		else
			echo " el GPRS no responde despues de 2 intentos"|tee -a $ARCHIVO_LOG
			return 1
		fi
	fi
}

function gprs_vivo
{
	timeout 15 wvdial prueba >> temp.txt 2>&1 
	HAY_IMEI=$(cat temp.txt|grep -A 1 CGSN|grep -v "CGSN") 
	if [ -z "HAY_IMEI" ]; then
		echo "No consigo el IMEI del GPRS"|tee -a $ARCHIVO_LOG
		return 1
	else
		echo "Numero de IMEI: $HAY_IMEI"|tee -a $ARCHIVO_LOG
		return 0
	fi
}


#GPS
function test_gps 
{
	echo ".......................probando GPS.............."|tee -a $ARCHIVO_LOG
	echo 1 > /sys/class/gpio/gpio81/value
	sleep 1
	echo 0 > /sys/class/gpio/gpio81/value
	if [ $(cat /sys/class/gpio/gpio84/value) -eq 1 ]; then
	        echo "GPS funcionando"|tee -a $ARCHIVO_LOG
	        gps_vivo
	else
	        echo "GPS no responde, reintento... "|tee -a $ARCHIVO_LOG
	        echo 1 > /sys/class/gpio/gpio81/value
			sleep 1
			echo 0 > /sys/class/gpio/gpio81/value
			if [ $(cat /sys/class/gpio/gpio84/value) -eq 1 ]; then
	        	echo "GPS funcionando"|tee -a $ARCHIVO_LOG
	        	gps_vivo
	        else
	        	echo "GPS no responde, despues de 2 intentos"|tee -a $ARCHIVO_LOG
		        return 1
		    fi
	fi
}

function gps_vivo 
{
	stty -F $PUERTO_GPS raw ispeed 4800 ospeed 4800
	timeout 5 cat $PUERTO_GPS >> sample_gps.txt
	if [-z $(cat sample.txt)]; then
		echo "el GPS no da tramas"|tee -a $ARCHIVO_LOG
		return 1
	else
		echo "GPS tramas ok"|tee -a $ARCHIVO_LOG
	fi
}

#Bluetooth
function test_bt
{
	echo ".......................probando Bluetooth.............."|tee -a $ARCHIVO_LOG
	devmem2 0x11400020 w 0x2222222 |tee -a $ARCHIVO_LOG
	insmod /lib/modules/3.8.13.30TwoNav/kernel/drivers/bluetooth/hci_uart.ko |tee -a $ARCHIVO_LOG
	echo 1 > /sys/class/gpio/gpio128/value |tee -a $ARCHIVO_LOG
	sleep 1
	hciattach -s 115200 /dev/ttySAC2 texas |tee -a $ARCHIVO_LOG
	HAY_BT=$(hciconfig)
	if [ -z "HAY_BT" ]; then
		echo "El Bluetooth no ha respondido"|tee -a $ARCHIVO_LOG
		return 1
	else
		echo "Bluetooth OK"|tee -a $ARCHIVO_LOG
		return 0
	fi
}

#Wi-Fi
function test_wifi
{
	echo ".......................probando Wi-Fi.............."|tee -a $ARCHIVO_LOG
	modprobe wlan18xx |tee -a $ARCHIVO_LOG # puede que no haga falta, o incluso sea peor cargarlo antes...
	echo 1 > /sys/class/gpio/gpio135/value |tee -a $ARCHIVO_LOG
	sleep 4
	dmesg|tail|tee -a $ARCHIVO_LOG
	HAY_WIFI=$(ifconfig|grep -A 8 -i wlan|tee -a $ARCHIVO_LOG)
	if [ -z "HAY_WIFI" ]; then
		echo "El modulo WI-Fi no responde"|tee -a $ARCHIVO_LOG
		return 1
	else
		echo "Wi-Fi OK"|tee -a $ARCHIVO_LOG
		return 0
	fi
}

#i2C tests
function test_i2c
{
	
}
#main
inicializar_gpios
test_gprs
test_gps
test_bt
test_wifi


exit 0

