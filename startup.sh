# Install Docker
## Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common

## Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

## The following command is to set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` stable" 

## Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version
sudo apt update 
sudo apt install -y docker-ce

# =======================
# Load .env
# export $(grep -v '^#' .env | xargs -d '\n')
export ENV=dev

# =======================
# Run validator
# ## Login to AWS
# aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 657460323073.dkr.ecr.region.amazonaws.com < password.json

# ## Pull image
# docker pull 657460323073.dkr.ecr.ap-southeast-1.amazonaws.com/spike-inu/indexer:b275ea17ce9ba84ec9923630531e6bafc2b6719e

# ## Run container
# docker run --env-file .env -d \
#     -p 80:1234
#     657460323073.dkr.ecr.ap-southeast-1.amazonaws.com/spike-inu/indexer:b275ea17ce9ba84ec9923630531e6bafc2b6719e
# docker login -u _json_key --password-stdin https://gcr.io < account.json
