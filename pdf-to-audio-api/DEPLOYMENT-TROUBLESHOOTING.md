# PDF to Audio API - VM Deployment Troubleshooting Guide

## 🔧 Quick Fix Steps

### 1. **Updated JAR with Network Binding**
The new JAR file now includes `server.address=0.0.0.0` which allows external access.

**✅ What was fixed:**
- Server now binds to all network interfaces (0.0.0.0:8085)
- Previously was only binding to localhost (127.0.0.1:8085)

### 2. **Deploy to Your VM**

**Copy the updated JAR to your VM:**
```
target\pdf-to-audio-api-1.0.0.jar
```

**Or run the deployment script:**
```powershell
.\deploy.ps1
```

### 3. **Windows Firewall Configuration**

**Manual command (run as Administrator):**
```powershell
New-NetFirewallRule -DisplayName "PDF to Audio API" -Direction Inbound -Protocol TCP -LocalPort 8085 -Action Allow -Profile Any
```

### 4. **Start the Application**
```cmd
java -jar pdf-to-audio-api-1.0.0.jar
```

**You should see:**
```
Tomcat started on port(s): 8085 (http) with context path '/'
```

---

## 🔍 Troubleshooting Steps

### **Issue: URL not accessible from outside**
**URL:** http://20.193.252.234:8085/

#### **Step 1: Check Application Binding**
When you start the JAR, look for this line:
```
Tomcat started on port(s): 8085 (http) with context path '/'
```

If you see binding errors, the application might not have started properly.

#### **Step 2: Test Local Access on VM**
On the VM, test:
```powershell
curl http://localhost:8085
```
If this doesn't work, the application itself has issues.

#### **Step 3: Check Windows Firewall**
```powershell
# Check if rule exists
Get-NetFirewallRule -DisplayName "PDF to Audio API"

# Check if port is open
netstat -an | findstr 8085
```

#### **Step 4: Check VM Network Security Groups**
- **Azure:** Network Security Groups (NSGs)
- **AWS:** Security Groups  
- **GCP:** Firewall Rules

**Ensure inbound rule exists:**
- Protocol: TCP
- Port: 8085
- Source: 0.0.0.0/0 (or your IP range)
- Action: Allow

#### **Step 5: Check Third-party Firewall Software**
Some VMs have additional firewall software:
- Windows Defender Firewall
- McAfee, Norton, etc.
- Cloud provider firewalls

#### **Step 6: Verify Application is Running**
```powershell
# Check if Java process is running
Get-Process java

# Check if port 8085 is being used
netstat -an | findstr 8085
```

Expected output:
```
TCP    0.0.0.0:8085    0.0.0.0:0    LISTENING
```

---

## 🌐 Cloud Provider Specific Steps

### **Microsoft Azure**
1. Go to Azure Portal → Virtual Machines → Your VM
2. Settings → Networking
3. Add inbound port rule:
   - Port: 8085
   - Protocol: TCP
   - Action: Allow
   - Source: Any

### **Amazon AWS**
1. Go to EC2 Console → Security Groups
2. Select your VM's security group
3. Add inbound rule:
   - Type: Custom TCP
   - Port: 8085
   - Source: 0.0.0.0/0

### **Google Cloud Platform**
1. Go to VPC Network → Firewall
2. Create firewall rule:
   - Direction: Ingress
   - Action: Allow
   - Ports: tcp:8085
   - Source IP ranges: 0.0.0.0/0

---

## 🧪 Testing Commands

### **Test from VM (should work):**
```powershell
curl http://localhost:8085
curl http://127.0.0.1:8085
```

### **Test from external (your goal):**
```powershell
curl http://20.193.252.234:8085
```

### **Check what's listening on port 8085:**
```powershell
netstat -an | findstr 8085
```

**Good result:**
```
TCP    0.0.0.0:8085    0.0.0.0:0    LISTENING
```

**Bad result (old configuration):**
```  
TCP    127.0.0.1:8085    0.0.0.0:0    LISTENING
```

---

## 📋 Deployment Checklist

- [ ] ✅ Updated JAR file with `server.address=0.0.0.0`
- [ ] ✅ JAR copied to VM
- [ ] ✅ Windows Firewall rule added for port 8085
- [ ] ✅ Cloud provider security group allows port 8085
- [ ] ✅ Application started successfully
- [ ] ✅ Local access works (`http://localhost:8085`)
- [ ] ✅ External access works (`http://20.193.252.234:8085`)

---

## 🆘 Still Not Working?

### **Get detailed logs:**
```cmd
java -jar pdf-to-audio-api-1.0.0.jar --debug
```

### **Check application properties:**
```cmd
java -jar pdf-to-audio-api-1.0.0.jar --spring.config.additional-location=application-debug.properties
```

Create `application-debug.properties`:
```properties
logging.level.org.springframework.web=DEBUG
logging.level.org.apache.tomcat=DEBUG
server.address=0.0.0.0
server.port=8085
```

### **Alternative port test:**
Try a different port to isolate the issue:
```cmd
java -jar pdf-to-audio-api-1.0.0.jar --server.port=8080
```

---

## 📞 Contact Information
If you're still having issues, check:
1. Application startup logs
2. Windows Event Viewer
3. Cloud provider's networking documentation
