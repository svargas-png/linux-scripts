#!/bin/bash
# ==============================================================
# Script:      menu.sh
# Descripción: Menú de gestión del sistema con funciones.
# Uso:
#   ./menu.sh                           -> menú interactivo
#   ./menu.sh 1 "Santi Vargas"        -> opción por número
#   ./menu.sh -a "Santi Vargas"       -> opción corta
#   ./menu.sh --add "Santi Vargas"    -> opción larga
# ==============================================================

# ---------------------- FUNCIONES -----------------------------

# mostrar_menu: muestra las opciones del menú.
# Parámetros: ninguno
mostrar_menu() {
    echo ""
    echo "===== MENÚ DE GESTIÓN ====="
    echo "1) Añadir usuario"
    echo "2) Eliminar usuario"
    echo "3) Información del sistema"
    echo "4) Espacio en disco"
    echo "5) Buscar usuario"
    echo "0) Salir"
    echo "==========================="
}

# mostrar_ayuda: explica cómo usar el script con parámetros.
# Parámetros: ninguno
mostrar_ayuda() {
    echo "Uso: ./menu.sh [opción] [argumento]"
    echo "  1 | -a | --add     \"Nombre Apellido\"  Añadir usuario"
    echo "  2 | -d | --del     \"Nombre Apellido\"  Eliminar usuario"
    echo "  3 | -i | --info                       Información del sistema"
    echo "  4 | -e | --espacio [ruta]             Espacio en disco"
    echo "  5 | -b | --buscar  \"Nombre Apellido\"  Buscar usuario"
    echo "  -h | --help                           Esta ayuda"
}

# generar_login: convierte "Santi Vargas" en "santi.vargas".
# Parámetros: $1 = nombre completo
generar_login() {
    local nombre="$1"
    echo "$nombre" | tr 'A-Z' 'a-z' | tr ' ' '.'
}

# anadir_usuario: crea un usuario a partir de su nombre completo.
# Parámetros: $1 = nombre completo (si no se pasa, se pregunta)
anadir_usuario() {
    local nombre="$1"
    local login

    if [ -z "$nombre" ]; then
        read -p "Nombre completo: " nombre
    fi

    login=$(generar_login "$nombre")

    if id "$login" &>/dev/null; then
        echo "El usuario $login ya existe."
    else
        sudo useradd -m -c "$nombre" "$login"
        echo "Usuario $login creado."
    fi
}

# eliminar_usuario: elimina un usuario y su carpeta personal.
# Parámetros: $1 = nombre completo (si no se pasa, se pregunta)
eliminar_usuario() {
    local nombre="$1"
    local login

    if [ -z "$nombre" ]; then
        read -p "Nombre completo a eliminar: " nombre
    fi

    login=$(generar_login "$nombre")

    if id "$login" &>/dev/null; then
        sudo userdel -r "$login" 2>/dev/null
        echo "Usuario $login eliminado."
    else
        echo "El usuario $login no existe."
    fi
}

# info_sistema: muestra datos básicos del sistema.
# Parámetros: ninguno
info_sistema() {
    echo "Equipo:  $(hostname)"
    echo "Kernel:  $(uname -r)"
    echo "Usuario: $(whoami)"
    echo "Fecha:   $(date)"
}

# espacio_disco: muestra el espacio en disco de una ruta.
# Parámetros: $1 = ruta (opcional, por defecto /)
espacio_disco() {
    local ruta="${1:-/}"
    df -h "$ruta"
}

# buscar_usuario: comprueba si un usuario existe.
# Parámetros: $1 = nombre completo (si no se pasa, se pregunta)
buscar_usuario() {
    local nombre="$1"
    local login

    if [ -z "$nombre" ]; then
        read -p "Nombre completo a buscar: " nombre
    fi

    login=$(generar_login "$nombre")

    if id "$login" &>/dev/null; then
        echo "El usuario $login existe."
    else
        echo "El usuario $login no existe."
    fi
}

# ejecutar_opcion: llama a la función que corresponde a la opción.
# Parámetros: $1 = opción, $2 = argumento (opcional)
ejecutar_opcion() {
    local opcion="$1"
    local argumento="$2"

    case "$opcion" in
        1|-a|--add)     anadir_usuario "$argumento" ;;
        2|-d|--del)     eliminar_usuario "$argumento" ;;
        3|-i|--info)    info_sistema ;;
        4|-e|--espacio) espacio_disco "$argumento" ;;
        5|-b|--buscar)  buscar_usuario "$argumento" ;;
        -h|--help)      mostrar_ayuda ;;
        0)              echo "Saliendo..." ;;
        *)              echo "Opción no válida. Usa --help." ;;
    esac
}

# ------------------- PROGRAMA PRINCIPAL -----------------------

if [ $# -eq 0 ]; then
    # Sin parámetros: menú interactivo hasta elegir 0
    opcion=""
    while [ "$opcion" != "0" ]; do
        mostrar_menu
        read -p "Elige una opción: " opcion
        ejecutar_opcion "$opcion"
    done
else
    # Con parámetros: ejecuta la opción y termina
    ejecutar_opcion "$1" "$2"
fi
