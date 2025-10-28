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
