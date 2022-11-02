# Validator

## 1. Install

- aws-cli
- terraform

## 2. How to run

- Download source: https://github.com/spike-inu/terraform-validator
- Run source:

    ```sh
    # each validator run on 1 workspace
    terraform workspace new validator-1

    # run
    terraform init
    terraform apply
    ```

- Destroy validator
    
    ```sh
    terraform destroy
    ```

- Check log: https://www.loom.com/share/bd02839a823d419c8168c54462f9caac