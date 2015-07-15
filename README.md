# Install
1. Clone this repo
2. `./scripts/install.sh`

# Run
1. To persist your jenkins changes make sure you have a persistent volume linked on `/var/jenkins_home`
2. `make start`

# Development
1. Make changes or pull them from the repository
2. `make rebuild` -> it will stop running container, rebuild the image, clean docker garbage and start jenkins again
