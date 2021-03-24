## ulb-omp

Server+DB: https://omp.bibliothek.uni-halle.de

# Install Docker 

# Installation GITLAB Runner

- curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"  
- sudo dpkg -i gitlab-runner_amd64.deb
- sudo gitlab-runner start
- sudo gitlab-runner status

# Neuen Runner anlegen für OMP

- visit: https://git.itz.uni-halle.de/ulb/ulb-ojs/-/settings/ci_cd

- sudo gitlab-runner register (URL / Token im ULB Gitlab kopieren)
    tags --> ulb-ojs,
    executer --> shell
    
