# Mini CA

## First Install

The scripts included all need to store persistent data somewhere. For this example, a local directory is used:

```shell
$ VOL=/var/lib/minica
```

Create the database for certificate storage and revokation.

```shell
$ *docker run -ti --rm -v $VOL:/certs dparrish/minica create_database.sh*
...
goose: migrating db environment 'development', current version: 0, target: 1
OK    001_CreateCertificates.sql
```

### Create the Root Certificate

First, edit the Root CA configuration. At the very least you should change the CN and OU values to something that makes sense to you.

```shell
$ *sudo vi $VOL/install/ca-csr.json*
```

Run the script that creates the Root CA certificate. This certificate is only used to generate an Intermediate certificate and should be protected.

```shell
$ *docker run -ti --rm -v $VOL:/certs dparrish/minica create_root.sh*
Creating Root Certificate.
2019/02/19 04:58:54 [INFO] generating a new CA key and certificate from CSR
2019/02/19 04:58:54 [INFO] generate received request
2019/02/19 04:58:54 [INFO] received CSR
2019/02/19 04:58:54 [INFO] generating key: ecdsa-256
2019/02/19 04:58:54 [INFO] encoded CSR
2019/02/19 04:58:54 [INFO] signed certificate with serial number 310123162380203327702166914002183066553285968238
```

### Set the base URL for OCSP and CRL

To validate and revoke certificates, a URL must be available to clients that use the CA's generated certificates. This URL should be served by the minica job. These URLs are configured in the `config.json` file, so you can edit that file directly or use the provided script to replace the placeholders automatically. For these instructions, `ca.dparrish.com` will be used for the base URL.

```shell
$ *docker run -ti --rm -v $VOL:/certs dparrish/minica set_base_url.sh ca.dparrish.com*
```

### Create the Intermediate Certificate

Run the script that creates the Intermediate CA certificate. This certificate is used to sign all certificate requests from clients.

```shell
$ *sudo vi $VOL/install/intermediate-csr.json*
$ *docker run -ti --rm -v $VOL:/certs dparrish/minica create_intermediate.sh*
2019/02/19 05:00:17 [INFO] generate received request
2019/02/19 05:00:17 [INFO] received CSR
2019/02/19 05:00:17 [INFO] generating key: ecdsa-256
2019/02/19 05:00:17 [INFO] encoded CSR
2019/02/19 05:00:17 [INFO] signed certificate with serial number 694464029169303736780477313118487302242919220637
2019/02/19 05:00:17 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
2019/02/19 05:00:17 [INFO] generate received request
2019/02/19 05:00:17 [INFO] received CSR
2019/02/19 05:00:17 [INFO] generating key: ecdsa-256
2019/02/19 05:00:17 [INFO] encoded CSR
2019/02/19 05:00:17 [INFO] signed certificate with serial number 471292738264490260574895146908956428084454001108
2019/02/19 05:00:17 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
```

### Start serving

Start the Mini-CA job serving:

```shell
$ *docker run -d --restart=always -P --name minica -v $VOL:/certs dparrish/minica*
```

You *should* remove the root certificate keypair from the container's volume and keep it offline. It is only ever used to generate a new Intermediate certificate.

```shell
$ *docker cp minica:/certs/root-key.pem .*
$ *docker cp minica:/certs/root.pem .*
$ *docker exec -ti minica shred_root.sh*
```

## Usage

The docker container exposes two ports, 80 and 8888. Port 80 runs a web server that provides `/ocsp`, `/crl` and `/bundle.pem`. These URLs are suitable for public visibility.

Port 8888 is the cfssl remote API which should be protected, as this can be used to sign certificates without authentication.

The author's setup uses a `traefik` proxy that exposes services to the outside world, so the following command makes port 80 available worldwide for CRL, and port 8888 only on localhost:

```shell
docker run -d --restart=always --name minica \
  -p 127.0.0.1:8888:8888 \
  -v $VOL:/certs \
  --label "traefik.port=80" \
  dparrish/minica
```

### Create and sign a certificate

```shell
$ openssl ecparam -name prime256v1 -out prime256v1.pem
$ openssl req -new -newkey ec:prime256v1.pem -nodes -keyout server.key -out server.csr
$ cfssl sign -remote localhost -profile server server.csr | cfssljson -bare server -
```

