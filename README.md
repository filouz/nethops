
<img align="right" src="https://i.imgur.com/mAv9fj4.png" height="140"/>

# NetHops

NetHops is a community app that enables you to establish a network hop. This provides your friends and community members with secure, domain-specific access, guaranteeing a tailored browsing experience for each user.

## Prerequisites

Docker must be installed and running on your system. [Install Docker](https://github.com/docker/docker-install)

## Server

### Setup


```bash
git clone https://github.com/filouz/nethops

./configure && make

make install # will erease the existing PKI
```


### Managing Profiles

- **Add a Profile**

    ```bash
    NAME="user"
    PASSWORD="strong_password"
    make addProfile name="$NAME" pwd="$PASSWORD"
    ```

- **Revoke a Profile**

    ```bash
    make revokeProfile name="$NAME"
    ```

- **Generate .ovpn Files**

    ```bash
    make ovpnProfile name="$NAME"
    ```

### How to Run

```bash
make run
```

For alternative running methods, refer to `docker/server/docker-compose.yaml`. You can also automate the deployment process using this [Ansible collection](https://github.com/filouz/ansible-nethops).

## Client

### Prerequisites

```bash
git clone https://github.com/filouz/nethops
```

Create a folder `./vault/ovpn` to store your credentials files.

- `client.ovpn`
    You can remove/comment these lines to espace auto configuration :
    ```config
    up /scripts/update-resolv.sh
    down /scripts/update-resolv.sh
    ```
- `client.pwd` (Optional: Contains the password in plaintext for silent mode.)

#### Using Openvpn Connect

To establish a connection with a NetHops server, utilize [OpenVPN Connect](https://openvpn.net/client/).

```bash
openvpn --script-security 2 --config ./.vault/ovpn/client.ovpn
```

Slient mode : 
```bash
openvpn --script-security 2 --config ./.vault/ovpn/client.ovpn --askpass ./.vault/ovpn/client.pwd
```

#### Using Docker

```bash
make client
```

#### Using docker-compose

- Use the `docker-compose.yaml` file located in `./docker/client/docker-compose.yaml`.

```bash
cd ./docker/client
docker compose up
```

#### Using Kubernetes as a Sidecar

Use the `nh_client.yaml` file located at `./deployment/nh_client.yaml`.

## 🌐 Restriction Domains

Modify the `./scripts/domains.conf` file to control which domains users can access via the VPN.

- **Example Structure**:

    ```
    .google.com
    .facebook.com
    .tiktok.com
    .ipify.org
    ```

- **Domain Specifications**: Prefix domains with a `.` to allow all subdomains. For example, `.google.com` would include access to subdomains like `mail.google.com`.

- **Applying Changes**: After updating the `domains.conf` file, restart the server to apply the changes.

## VPN Client API

When the VPN client is running, an API is available on port 8080 for VPN connection management:

- **Endpoints**:

    - `/start`: Starts the VPN connection.
    - `/stop`: Stops the active VPN connection.
    - `/healthz`: Checks the service status (returns the current state of the service).

## Credits
This project incorporates components from [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn)


## Contributing

Your contributions are welcome! If you find bugs or have suggestions for enhancements, please create an issue or submit a pull request.

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).