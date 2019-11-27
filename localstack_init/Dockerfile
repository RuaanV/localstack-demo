
FROM hashicorp/terraform:0.11.14

ADD ./localstack_init/local.tf .
ADD ./localstack_init/variables.tf .

ADD ./functions/ .

RUN terraform init