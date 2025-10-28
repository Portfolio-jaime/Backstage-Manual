# Scripts de Utilidad

Esta carpeta contiene scripts de automatización para facilitar el desarrollo y gestión del proyecto Backstage.

## switch_git_profile.py

### Descripción
Script en Python que permite alternar entre diferentes perfiles de Git (personal y laboral) para gestionar repositorios con diferentes identidades.

### Funcionalidad
- Cambia el usuario y email de Git en el repositorio actual
- Actualiza la URL del remoto `origin` al correspondiente del perfil
- Soporta perfiles personal y laboral

### Perfiles Configurados

#### Personal (`Portfolio-jaime`)
- **Usuario**: Portfolio-jaime
- **Email**: jaimehenao8126@outlook.com
- **Remoto**: git@github-portfolio:Portfolio-jaime/Backstage-Manual.git

#### Laboral (`jhenao-nex`)
- **Usuario**: jhenao-nex
- **Email**: jaime.andres.henao.arbelaez@ba.com
- **Remoto**: git@github.com:empresa/repo.git

### Uso

```bash
# Cambiar al perfil personal
python Scripts/switch_git_profile.py personal

# Cambiar al perfil laboral
python Scripts/switch_git_profile.py laboral
```

### Requisitos
- Python 3.x instalado
- Ejecutar desde la raíz del repositorio Git
- Claves SSH configuradas para cada perfil en `~/.ssh/config`

### Ejemplo de Salida
```
Perfil 'personal' configurado correctamente.
```

### Personalización
Para agregar más perfiles, edita el diccionario `profiles` en el script:

```python
profiles = {
    "nuevo_perfil": {
        "user": "usuario-nuevo",
        "email": "email@nuevo.com",
        "remote": "git@github-nuevo:usuario/repo.git"
    }
}
```

## Estructura del Script

```python
import subprocess
import sys

# Configuraciones de perfiles
profiles = {
    "personal": {
        "user": "Portfolio-jaime",
        "email": "jaimehenao8126@outlook.com",
        "remote": "git@github-portfolio:Portfolio-jaime/Backstage-Manual.git"
    },
    "laboral": {
        "user": "jhenao-nex",
        "email": "jaime.andres.henao.arbelaez@ba.com",
        "remote": "git@github.com:empresa/repo.git"
    }
}

def set_profile(profile):
    if profile not in profiles:
        print(f"Perfil '{profile}' no encontrado.")
        sys.exit(1)
    p = profiles[profile]
    subprocess.run(["git", "config", "user.name", p["user"]])
    subprocess.run(["git", "config", "user.email", p["email"]])
    subprocess.run(["git", "remote", "set-url", "origin", p["remote"]])
    print(f"Perfil '{profile}' configurado correctamente.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python switch_git_profile.py [personal|laboral]")
        sys.exit(1)
    set_profile(sys.argv[1])
```

## Casos de Uso

### Desarrollo Personal
Cuando trabajas en el proyecto para tu portfolio personal:
```bash
python Scripts/switch_git_profile.py personal
```

### Desarrollo Laboral
Cuando trabajas en el proyecto para fines laborales:
```bash
python Scripts/switch_git_profile.py laboral
```

## Configuración de SSH

Para que el script funcione correctamente, asegúrate de tener configurado `~/.ssh/config`:

```
# Perfil Personal
Host github-portfolio
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_portfolio

# Perfil Laboral
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_laboral
```

## Solución de Problemas

### Error: "Perfil no encontrado"
- Verifica que el nombre del perfil esté escrito correctamente
- Los perfiles disponibles son: `personal`, `laboral`

### Error: "Permission denied (publickey)"
- Verifica que las claves SSH estén configuradas correctamente
- Asegúrate de que las claves públicas estén agregadas a las cuentas de GitHub correspondientes

### Error: "No such file or directory"
- Ejecuta el script desde la raíz del repositorio Git
- Verifica que estés en un directorio que contenga `.git`

## Mejores Prácticas

1. **Backup**: Haz backup de tu configuración Git antes de usar el script
2. **Verificación**: Siempre verifica el perfil activo con `git config user.name`
3. **Consistencia**: Usa el mismo perfil para commits relacionados
4. **Documentación**: Mantén actualizada la documentación de perfiles

## Futuras Mejoras

- Soporte para más perfiles
- Validación automática de configuración SSH
- Interfaz gráfica (GUI)
- Integración con gestores de credenciales
- Backup automático de configuración actual

## Contribución

Para contribuir con mejoras al script:

1. Crea una rama para tu feature
2. Implementa los cambios
3. Actualiza esta documentación si es necesario
4. Envía un pull request

## Soporte

Si encuentras problemas con el script, verifica:
- La instalación de Python
- La configuración de SSH
- Los permisos del repositorio
- La sintaxis del comando