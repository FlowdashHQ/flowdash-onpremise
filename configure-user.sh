dir=$(pwd)
echo "Adding $(whoami) to docker group to execute docker as non-root"
sudo usermod -aG docker $(whoami)
sudo su - $(whoami)
cd $(dir)
echo "Log in to docker so you can pull the image"
docker login
