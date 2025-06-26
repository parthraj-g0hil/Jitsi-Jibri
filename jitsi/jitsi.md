# Jitsi Meet Installation Guide on Ubuntu

## 1. Update System Packages

```bash
sudo apt update
```

## 2. Install `apt-transport-https`

```bash
sudo apt install apt-transport-https
```

## 3. Add Universe Repository

```bash
sudo apt-add-repository universe
```

## 4. Set Hostname

```bash
sudo hostnamectl set-hostname jitsi.parthraj.cloud
```

## 5. Edit `/etc/hosts` File

```bash
sudo vim /etc/hosts
```

Add the following line:
```
<Public-IP> jitsi.parthraj.cloud
```

## 6. Test Hostname Resolution

```bash
ping "$(hostname)"
```

---

## 7. Add the Prosody Package Repository

```bash
sudo curl -sL https://prosody.im/files/prosody-debian-packages.key -o /usr/share/keyrings/prosody-debian-packages.key
echo "deb [signed-by=/usr/share/keyrings/prosody-debian-packages.key] http://packages.prosody.im/debian $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/prosody-debian-packages.list
sudo apt install lua5.2
```

---

## 8. Add the Jitsi Package Repository

```bash
curl -sL https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo "deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/" | sudo tee /etc/apt/sources.list.d/jitsi-stable.list
```

---

## 9. Update Packages Again

```bash
sudo apt update
```

---

## 10. Install Jitsi Meet

```bash
sudo apt install jitsi-meet
```

---

## 11. Configure Videobridge

Edit the following file:

```bash
sudo vim /etc/jitsi/videobridge/jvb.conf
```

Add the following content:

```hocon
videobridge {
  ice4j {
    harvest {
      mapping {
        aws {
          enabled = true
          force = true
        }
        stun {
          addresses = []
        }
        static-mappings = []
      }
    }
  }
}
```

---

## 12. Restart Jitsi Videobridge

```bash
sudo systemctl restart jitsi-videobridge2
```

---

## 13. Important Log Files

- `/var/log/jitsi/jvb.log`
- `/var/log/jitsi/jicofo.log`
- `/var/log/prosody/prosody.log`
