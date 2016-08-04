#!/bin/bash

#-----------------------------------------------------------------
# Prueba gpios para velo. Perpetrado por Arturo Sapiña. Julio 2016
#-----------------------------------------------------------------


#-----------------INICIALIZAR TODO-------------------------------
if false
then
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
fi

#---------------WLAN----------------------
echo 228 > /sys/class/gpio/export #wlan-enable
echo out > /sys/class/gpio/gpio135/direction

echo 230 > /sys/class/gpio/export #bt-enable
echo out > /sys/class/gpio/gpio128/direction

echo 200 > /sys/class/gpio/export #wlan-osc-en
echo out > /sys/class/gpio/gpio128/direction

echo 217 > /sys/class/gpio/export #wlan irq
echo in > /sys/class/gpio/gpio128/direction

if false
then
#-------------botones--------------------

echo 111 > /sys/class/gpio/export #topleft
echo in > /sys/class/gpio/gpio111/direction

echo 78 > /sys/class/gpio/export #topright
echo in > /sys/class/gpio/gpio78/direction

echo 123 > /sys/class/gpio/export #botright
echo in > /sys/class/gpio/gpio123/direction

echo 132 > /sys/class/gpio/export #botleft
echo in > /sys/class/gpio/gpio132/direction

#---------------otros-------------------

echo 10 > /sys/class/gpio/export #3v3 pow enable
echo out > /sys/class/gpio/gpio10/direction


#--------------------TESTS--------------------
fi
#GPRS
if false
then
echo " probando GPRS...."
echo 0 > /sys/class/gpio/gpio57/value
echo 1 > /sys/class/gpio/gpio51/value
sleep 2
echo 0 > /sys/class/gpio/gpio51/value 
if [ $(cat /sys/class/gpio/gpio62/value) -eq 1 ]; then
	echo " GPRS funcionando"
else
	echo " el GPRS no responde "
fi

#GPS

echo " probando GPS...."
echo 1 > /sys/class/gpio/gpio81/value
sleep 1
echo 0 > /sys/class/gpio/gpio81/value
if [ $(cat /sys/class/gpio/gpio84/value) -eq 1 ]; then
        echo "GPS funcionando"
else
        echo " el GPS no responde "
fi

exit 0

fi

# prueba wifi

echo " activar el ldo 14 "
i2cset -y -f -r 0 0x09 0x4d 0xd4

echo " enciende oscilador "
echo 1 > /sys/class/gpio/gpio200/value

echo " enciende wifi "
echo 1 > /sys/class/gpio/gpio228/value

if [ $(cat /sys/class/gpio/gpio217/value) -eq 1 ];then
	echo " el wifi dice que todo ok"
else
	echo " el wifi pasa de ti "
fi
exit 0






