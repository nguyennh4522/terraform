# CLI

## 1. Connect to cluster

- Install kubectl (kubenetes client): https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/

  ```sh
  brew install kubectl
  ```

- Install AWS CLI (auth to connect to cluster): https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

  ```sh
  # macOS
  curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
  sudo installer -pkg AWSCLIV2.pkg -target /
  ```

- Add credentials
  - Get access key ID + secret access key: https://docs.aws.amazon.com/sdk-for-javascript/v2/developer-guide/getting-your-credentials.html
  - Make file ~/.aws/credentials

    ```sh
    nano ~/.aws/credentials
    ```

  - Add access key ID + secret access key to ~/.aws/credentials

    ```
    [default]
    aws_access_key_id = <key_id>
    aws_secret_access_key = <access_key>
    ```


- Install k9s

  ```sh
  brew install derailed/k9s/k9s
  ```

- Connect to cluster:

  ```
  k9s
  ```

## 2. Interactive with kubernetes

- Get namespace

  ```
  kubectl get ns
  ```

- Get resource in namespace (pod, service, deployment, secret, ingress,...): `kubectl -n <namespace> get <resource>`

  ```
  kubectl -n spike-inu-dev get pod
  kubectl -n spike-inu-dev get deploy
  kubectl -n spike-inu-dev get svc
  kubectl -n spike-inu-dev get secret
  kubectl -n spike-inu-dev get ingress
  ...
  ```

- Describe resource: `kubectl -n <namespace> describe <resource type> <resource id>`

  ```
  kubectl -n spike-inu-dev describe pod indexer-78cb684f7-9n9rl
  ```

- Create/Update resource: `kubectl -n <namespace> apply -f <file>`

  ```
  kubectl -n spike-inu-dev apply -f ./deployment.yml
  ```

- Restart service when error appear

  ```
  kubectl -n spike-inu-dev rollout restart deployment indexer
  ```



## 3. Debugging

- Các trạng thái của pod (cột `STATUS`)
  - `Running`: đang chạy ổn định
  - `Running` (nhưng số lần restart > 0): pod vừa restart
  - `Error`: Pod gặp error và không thể start
  - `OOMKilled`: Thường là do leak memory, hoặc memory tăng bất thường dẫn đến thiếu memory

- Khi có service restart, sẽ có alert gửi đến channel trong discord (setting tron grafana). Để kiểm tra thông tin về lần restart đó:
  - Truy cập k9s
  - Switch to pod
  - Move up/down đến pod đã restart
  - Type `p` -> `0` đễ xem log trước khi restart

- Khi service không thê start:
  - Do code lỗi, không thể run được
  - Do thiếu resource
  - Do thay đổi config
