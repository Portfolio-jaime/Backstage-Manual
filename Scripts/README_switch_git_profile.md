# Guía de uso: switch_git_profile.py

Este script te permite alternar entre perfiles de Git (usuario, email y remoto) para proyectos personales y laborales.

## Ubicación del script
`Scriptsd/switch_git_profile.py`

## Perfiles disponibles
- **personal**: Portfolio-jaime
- **laboral**: jhenao-nex

## Comandos principales

### Cambiar al perfil personal
```sh
python Scriptsd/switch_git_profile.py personal
```

### Cambiar al perfil laboral
```sh
python Scriptsd/switch_git_profile.py laboral
```

## ¿Qué hace el script?
- Cambia el usuario y email de Git en el repositorio actual.
- Cambia la URL del remoto `origin` al correspondiente del perfil.
- Muestra un mensaje de confirmación.

## Ejemplo de salida
```
Perfil 'personal' configurado correctamente.
```

## Requisitos
- Tener Python instalado.
- Ejecutar el script desde la raíz del repositorio.
- Tener configuradas las claves SSH y el archivo `~/.ssh/config` para cada perfil.

## Personalización
Puedes agregar más perfiles editando el diccionario `profiles` dentro del script.

---
¿Dudas o necesitas agregar más perfiles? Edita el script o consulta a GitHub Copilot.
