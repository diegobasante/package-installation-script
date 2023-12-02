#!/bin/bash

indice=0

# Comprobamos que el usuario que ejecuta el script sea root
# Actualizamos los repositorios

if [[ $EUID -eq 0 ]]; then

	sudo apt update &>/dev/null
	echo "Actualizando los repositorios..."

else

	echo "Este script debe ejecutarse como root."
	exit 1

fi

# Creamos el bucle para recorrer el ficheiro y guardamos los valores en cada vector

while IFS=":" read package action;
do

	vPaquete[${indice}]=$package
	vAction[${indice}]=$action


	# Comprobamos si el paquete está o no instalado

	comprobarPaquete=$(whereis ${vPaquete[$indice]} | grep bin | wc -l)

	case ${vAction[$indice]} in

	"add" | "i" )

		# En caso de que el paquete seleccionado sea chrome ejecute unos comandos concretos

		if [[ ${vPaquete[$indice]} == "google-chrome" ]]; then

			echo "Instalando ${vPaquete[$indice]}..."
			wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &>/dev/null

			# Instalamos a libreria de indicadores de sistema
			# Non é necesaria para a instalación de Chrome, pero si nos permite ver o seu icono

			sudo apt-get install libappindicator1 &>/dev/null
			sudo dpkg -i google-chrome-stable_current_amd64.deb &>/dev/null
			rm google-chrome-stable_current_amd64.deb

		fi

		# Lo mismo para atom, que no podemos instalarlo con apt

		if [[ ${vPaquete[$indice]} == "atom" ]]; then

           	echo "Instalando ${vPaquete[$indice]}..."
			wget https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb &>/dev/null
			dpkg -i atom-amd64.deb &>/dev/null
			rm atom-amd64.deb

           fi

		# En cualquier otro caso se realiza la instalación

		if [[ $comprobarPaquete -eq 0 ]]; then

			echo "${vPaquete[$indice]} no está instalado. Procedemos con la instalación..."
			sudo apt install ${vPaquete[$indice]} -y &>/dev/null

		else

			echo "${vPaquete[$indice]} ya está instalado. Continuamos la ejecución..."

		fi

	;;

	"remove" | "r" )

		# Comprobamos que el paquete está instalado

		if [[ $comprobarPaquete -ne 0 ]]; then

			echo "${vPaquete[$indice]} está instalado. Procedemos a eliminarlo..."
			sudo apt remove ${vPaquete[$indice]} -y &>/dev/null
			sudo apt purge ${vPaquete[$indice]} -y &>/dev/null

		else

			echo "${vPaquete[$indice]} no existe. Continuamos la ejecución..."

		fi

	;;



	"status" | "s" )

		if [[ $comprobarPaquete -ne 0 ]]; then

    		echo "------------${vPaquete[$indice]} está instalado--------------"

		else

       		echo "------------${vPaquete[$indice]} no está instalado--------------"

		fi

	;;

	# Por si no se reconoce una determinada acción

	"*" )

		echo "Accion no reconocida para ${vPaquete[$indice]}"

	;;

	esac

	((indice++))

done < packages.txt

echo "Ejecución terminada."

