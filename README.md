# Install
1. Clone this repo
2. `./install.sh`

# Run
To persist your jenkins changes make sure you have a persistent volume linked on `/var/jenkins_home`
`make start`

# Development
1. `docker stop jenkins-server-container`
2. Make changes to the files
3. `make cleanup`
4. `make build`
5. `make start`
