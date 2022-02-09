# Run Flowdash on Kubernetes with Helm

This folder contains instructions for deploying Flowdash on your own kubernetes infrastructure using Helm.

**Note**: There are a million ways to skin a cat. This is just one.

These deployment instructions assume the following infrastructure:
* Postgres database (e.g., AWS RDS)
* Redis instance (e.g., AWS ElastiCache)
* Kubernetes cluster (e.g., AWS EKS)
* LoadBalancer (e.g., EC2)
* VPC
* S3 Bucket
* Access to the Flowdash Docker image registry
* Google OAuth Client

Pre-Requisites
1. Access to an AWS account (for AWS resource creation)
2. Access to Google Workspace (for Oauth client creation)



High level instructions
1. Clone this repository into the machine you use to manage your k8s infra.
2. `cd` into the `helm` directory.
3. Create a new kubernetes cluster (e.g., called `flowdash-eks-cluster`) in the VPC of your choice.
4. [Install](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html#lbc-install-controller ) the AWS network load balancer controller on your cluster. We'll need it to create the `LoadBalancer` k8s service object.
5. Create a postgres instance with `flowdash_production` as the database name. We'll need the credentials for `helm/values.yaml`. Make sure it's in the same VPC.
6. Create a redis instance. We'll need the host for `helm/values.yaml`. Make sure it's in the same VPC.
7. Create an S3 bucket. We'll need the access id, secret, name, and region for `helm/values.yaml`.
8. Create a Google OAuth Client. We'll need the client id and secret from `helm/values.yaml`.
9. Update `helm/values.yaml` with the appropriate values (see below for instructions).
10. Deploy with helm.
```bash
$ helm package helm
# Successfully packaged chart and saved it to: /home/ec2-user/flowdash-onpremise/flowdashchart-0.1.0.tgz

$ helm install flowdash-release1 flowdashchart-0.1.0.tgz
$ watch -n1 'kubectl get pods'

# Delete migration job when migration finishes
$ kubectl delete job migration-flowdash

# Retrieve the created LoadBalancer host for an environment variable.
$ kubectl get svc

# In values.yaml, change config.hostUrl to the LoadBalancer value
# Update your Google Oauth Client to use this value as the origin and callback values.

# Now you may upgrade and re-deploy the app
$ helm package helm
$ helm upgrade flowdash-release1 flowdashchart-0.1.0.tgz

# Visit the host value for the LoadBalancer to log in!
```

### Values.yaml: Please modify the following values in `helm/values.yaml` before you deploy
```
config.licenseKey               # Flowdash will provide this
config.hostUrl                  # Service url you're using
config.auth.google.clientId     # Google client ID you generated
config.auth.google.clientSecret # Google client secret you generated
config.secretKeyBase            # You may use the output of this bash command => openssl rand -hex 64
config.attrEncryptedKey         # You may use the output of this bash command => openssl rand -hex 32
config.hashIdSalt               # You may use the output of this bash command => openssl rand -hex 32
config.postgresql.*             # Please set host, user, and password for your database
config.redis.url                # Your redis host url
config.s3.*                     # Your S3 bucket configuration. Please follow instructions in the main repo readme for s3 bucket setup
config.smtp.*                   # Your SMTP bucket configuration. Please follow instructions in the main repo readme for SMTP client setup

image.repository                # The Flowdash image registry
image.tag                       # The image tag you'd like to deploy

# If you choose to deploy with SSL enabled, please change the following default configuration
config.useInsecureCookies=false
config.forceSsl="enabled"
```

