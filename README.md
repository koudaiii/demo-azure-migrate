# demo-azure-migrate

## Require

- azure subscription
- install az cli
- connect azure vm using vpn

## Set up

```console
$ script/bootstrap.sh
```

## Self-signed root certificate

```console
$ openssl genrsa -out ~/.ssh/caKey.pem 2048
$ openssl req -x509 -new -nodes -key ~/.ssh/caKey.pem -subj "/CN=VPN CA" -days 3650 -out ~/.ssh/caCert.pem
```

ref https://learn.microsoft.com/ja-jp/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal#uploadfile

- for macOS user

```console
$ openssl x509 -in ~/.ssh/caCert.pem -outform der | base64 | pbcopy
```

## Generate Client cert

```console
# Generate a private key
$ openssl genrsa -out "~/.ssh/koudaiiiKey.pem" 2048

# Generate a CSR (Certificate Sign Request)
$ openssl req -new -key ~/.ssh/koudaiiiKey.pem -out ~/.ssh/koudaiiiReq.pem -subj "/CN=koudaiii"

# Sign the CSR using the CA certificate and CA key
$ openssl x509 -req -days 365 -in ~/.ssh/koudaiiiReq.pem -CA ~/.ssh/caCert.pem -CAkey ~/.ssh/caKey.pem -CAcreateserial -out ~/.ssh/koudaiiiCert.pem -extfile <(echo -e "subjectAltName=DNS:koudaiii\nextendedKeyUsage=clientAuth")

# Verify
$ openssl verify -CAfile ~/.ssh/caCert.pem ~/.ssh/caCert.pem ~/.ssh/koudaiiiCert.pem
```


## Install Azure Migrate Appliance

ref https://learn.microsoft.com/ja-jp/azure/migrate/tutorial-discover-physical
