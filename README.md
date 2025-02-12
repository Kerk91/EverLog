# **EverLog - Session Logging on Blockchain**

EverLog is a Proof of Concept (POC) that demonstrates how server session events can be securely logged and stored immutably on the blockchain. This repository contains two Bash scripts:

1. **Encrypted Version:** Logs session events with AES-256 encryption.(Can be modified to use any other algorithms that includes one way hashing)
2. **Plain Text Version:** Logs session events in plain text.

---

## **Background**

In scenarios where attackers gain root access to a server, the entire system is likely compromised. Even with the use of AI detection, the data may be unreliable due to potential data poisoning by attackers. This poses a significant challenge to ensuring data integrity and security.

By posting session data directly onto the blockchain, EverLog provides a tamper-proof mechanism that ensures the integrity of the data. This approach allows AI systems to analyze session data with confidence, free from concerns about data tampering or modification.

While existing solutions, such as logging session data to a remote server, can provide some level of protection, they are not foolproof. If an attacker gains access to one server, there is a high probability they could silently infiltrate other connected systems, modifying or deleting traces of their activities.

EverLog addresses these challenges by leveraging blockchain technology to log each session immutably. This ensures that the data remains secure and untampered, improving a company's overall data quality and offering a reliable source for AI-driven analysis. 

---

## **Features**

- **Immutable Logging:** Data is posted to the Stability blockchain, ensuring tamper-proof records.
- **Encryption Support:** Secure sensitive data with AES-256 encryption (optional).
- **Blockchain Transparency:** Provides transaction URLs for logged events.
- **Customizable:** Configure server IDs, API endpoints, and encryption settings.

---

## **Scripts**

### **1. Encrypted Version**
- **Path:** `login_post_request_encrypted.sh`
- **Description:** Encrypts session event data using AES-256 before posting it to the blockchain.
- **Use Case:** Ideal for logging sensitive information securely.

### **2. Plain Text Version**
- **Path:** `login_post_request_plain.sh`
- **Description:** Logs session event data in plain text for simplicity.
- **Use Case:** Useful for non-sensitive logs or lightweight setups.

---

## **Configuration**

### **Setup**

1. Choose the Bash script suitable for your use case (encrypted or plain text).

2. Save the script into an appropriate directory. In this example, the scripts are stored under:
   ```
   /usr/local/bin/login_post_request.sh
   /usr/local/bin/login_post_request_encrypted.sh
   ```

3. Edit the API endpoint and configuration in the scripts:
   - `API_URL`: Stability blockchain endpoint (get your API key [here](https://portal.stabilityprotocol.com/keys)).
   - `SERVERID`: Unique identifier for your server.
   - `PASS`: Secure password for encryption (encrypted version only).

4. Make the scripts executable:
   ```bash
   chmod +x /usr/local/bin/login_post_request.sh
   chmod +x /usr/local/bin/login_post_request_encrypted.sh
   ```

---

## **Enable Post Logging for Each Session**

To enable automatic post logging for every session, follow these steps:

1. Edit the PAM configuration for SSH:
   ```bash
   sudo nano /etc/pam.d/sshd
   ```

2. Add the following lines to the file:
   ```bash
   session optional pam_exec.so /usr/local/bin/login_post_request.sh
   session optional pam_exec.so /usr/local/bin/login_post_request_encrypted.sh
   ```

### **What Does This Do?**
- These lines configure PAM (Pluggable Authentication Module) to invoke the respective scripts during session-related events for SSH.
- **Plain Text Script:** Logs session data in plain text and posts it to the blockchain.
- **Encrypted Script:** Encrypts the session data before posting to the blockchain for added security.

3. Restart the SSH service to apply changes:
   ```bash
   sudo systemctl restart sshd
   ```

---

## **Testing**

### **Run the Plain Text Version**
```bash
PAM_USER="testuser" PAM_RHOST="127.0.0.1" PAM_TYPE="open_session" ./login_post_request_plain.sh
```

### **Prerequisite**
Ensure OpenSSL is installed on the system to run the encrypted version:

### **Run the Encrypted Version**
```bash
PAM_USER="testuser" PAM_RHOST="127.0.0.1" PAM_TYPE="open_session" ./login_post_request_encrypted.sh
```

---

## **Log Output**

Logs are stored in `/var/log/login_post_request.log`:

```
Wed Jan 20 12:00:00 UTC 2025: Triggered login_post_request.sh for IP: 127.0.0.1
Wed Jan 20 12:00:01 UTC 2025: POST request succeeded for IP: 127.0.0.1
Wed Jan 20 12:00:01 UTC 2025: Transaction URL: https://stability.blockscout.com/tx/0xae6cd6699cd7ae5682edb0182911ca856432a9dcde4bfa909faa01bd74c24dc0
```

---

## **Customization**

### **Encryption Command**
You can use your own encryption method, in this example we are using open ssl aes 256:
```bash
ENCRYPTION_COMMAND="openssl enc -aes-256-cbc -a -A -salt -pass pass:$PASS"
```

### **Event Data**
Feel free to customize the fields you would like to logged (e.g., add/remove fields):
```bash
EVENT="ServerID:$SERVERID, User: $USER, IP: $IP_ADDRESS, Service: $SERVICE, Timestamp: $TIMESTAMP, SessionType: $SESSION_TYPE"
```

---

## **Stability Blockchain**

EverLog uses the [Stability blockchain](https://stabilityprotocol.com) for:

- **Feeless Transactions:** No cost for storing data.
- **Scalability:** Handles high transaction volumes effortlessly.
- **Token-Free Access:** Simplified user experience without cryptocurrency dependencies.

---

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
