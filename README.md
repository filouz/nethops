

<img align="right" src="https://github.com/filouz/nethops/assets/3224369/1dba14f4-bba3-42c6-9711-cea0cea77de5" height="140"/>


# Net`Hops`

A community app that lets you establish a network Hop, giving friends and community members secure, domain-specific access, ensuring a tailored browsing experience for each user.

##  Requirements
- **Docker**: Install from [Docker official repository](https://github.com/docker/docker-install).

## 🚀 Server Setup
### Installation 
```bash
./configure && make
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

### Starting the Server
```bash
make start
```

For alternative run methods, see `docker/server/docker-compose.yaml`

##  Client Setup
Prepare the necessary files: 
- `client.ovpn`
- `client.pwd` (Optional: Contains the password in plaintext for silent mode.)

### **DID #dockerINdocker**
```bash
make client
```

### **docker-compose**
- Use the `docker-compose.yaml` file found at `./docker/client/docker-compose.yaml`.
- Customize as needed.
- Start the VPN client:

```bash
docker-compose up
```

### **Kubernetes - as sidecar**

Use the `nh_client.yaml` file located at `./deployment/nh_client.yaml`.

## 🌐 Managing Domains

Modify the `./scripts/domains.conf` file to control which domains users can access via the VPN.

- **Example Structure**:
    ```
    .google.com
    .facebook.com
    .tiktok.com    
    .ipify.org
    ```

- **Domain Specifications**: Domains prefixed with a `.` allow all subdomains. For example, `.google.com` allows access to subdomains like `mail.google.com`.

- **Applying Changes**: After updating the `domains.conf` file, restart the server for the changes to apply.

##  VPN Client API
When the VPN client is running, an API on port ***8080*** is available for VPN connection management:

- **Endpoints**:
    - `/start`: Start the VPN connection.
    - `/stop`: Stop the active VPN connection.
    - `/healthz`: Check service status (returns the current state of the service).

## Contributing
Your contributions are appreciated! If you discover bugs or have enhancement suggestions, please create an issue or submit a pull request.

## License
This project is licensed under the GNU General Public License v3.0 (GPLv3).