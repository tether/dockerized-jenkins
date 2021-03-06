# Install
1. Clone this repo
2. `./scripts/install.sh`

# Run
1. To persist your jenkins changes make sure you have a persistent volume linked on `/var/jenkins_home`
2. `make start`

# Development
1. Make changes or pull them from the repository
2. `make rebuild` -> it will stop running container, rebuild the image, clean docker garbage and start jenkins again

# Restoring backups on your local machine
1. `mkdir -p .docker-dev/backup`
2. `scp -r -i <YOUR_KEY> USER@HOST:/mnt/backup .docker-dev`
3. Go to http://localhost:8080/thinBackup/backupsettings and ensure the backup dir is set to `/mnt/backup`
4. Go to http://localhost:8080/thinBackup/restoreOptions and restore the backup you just downloaded
5. `sed -i 's|jenkins\.example\.com|localhost|g' .docker-dev/jenkins_home/jenkins.model.JenkinsLocationConfiguration.xml`
6. `sed -i 's|<useSecurity>true</useSecurity>|<useSecurity>false</useSecurity>|g' .docker-dev/jenkins_home/config.xml`
7. Go to http://localhost:8080/manage and `Reload Configuration from Disk`
