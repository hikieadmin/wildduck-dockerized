# WildDuck Email Suite - Railway Deployment

Bu proje WildDuck email suite'ini Railway platformunda deploy etmek için optimize edilmiştir.

## Railway'de Deploy Etme

### 1. Railway Hesabı Oluşturma
1. [Railway.app](https://railway.app) adresine gidin
2. GitHub hesabınızla giriş yapın
3. Yeni bir proje oluşturun

### 2. Projeyi Railway'e Deploy Etme

#### Yöntem 1: GitHub Repository ile
1. Bu projeyi GitHub'a push edin
2. Railway dashboard'da "New Project" > "Deploy from GitHub repo" seçin
3. Repository'nizi seçin

#### Yöntem 2: Railway CLI ile
```bash
# Railway CLI'yi yükleyin
npm install -g @railway/cli

# Login olun
railway login

# Projeyi deploy edin
railway up
```

### 3. Environment Variables Ayarlama

Railway dashboard'da aşağıdaki environment variable'ları ekleyin:

```env
# Domain configuration
MAILDOMAIN=your-domain.com
HOSTNAME=your-domain.com

# Database credentials
MONGO_USERNAME=admin
MONGO_PASSWORD=your-secure-mongo-password
REDIS_PASSWORD=your-secure-redis-password

# Email configuration
ACME_EMAIL=admin@your-domain.com

# Application settings
NODE_ENV=production
PORT=8080

# SSL/TLS settings
USE_SELF_SIGNED_CERTS=false
FULL_SETUP=true
```

### 4. Custom Domain Ayarlama

1. Railway dashboard'da "Settings" > "Domains" bölümüne gidin
2. Custom domain ekleyin
3. DNS kayıtlarınızı güncelleyin:
   ```
   A record: @ -> Railway IP
   CNAME: mail -> your-app.railway.app
   MX record: @ -> mail.your-domain.com (priority: 10)
   ```

### 5. Email Servisleri için Port Ayarları

Railway'de email portları için özel ayarlar gerekebilir:

- **SMTP (25)**: Giden email için
- **IMAP (143/993)**: Email okuma için
- **POP3 (110/995)**: Email indirme için
- **Submission (587)**: Email gönderme için
- **Web Interface (8080)**: Webmail arayüzü

### 6. SSL/TLS Sertifikaları

Production ortamında Let's Encrypt sertifikaları otomatik olarak oluşturulur. Development için self-signed sertifikalar kullanılır.

## Servisler

### WildDuck IMAP/POP3 Server
- Port: 143 (IMAP), 110 (POP3)
- SSL Portları: 993 (IMAPS), 995 (POP3S)

### WildDuck Webmail
- Port: 3000
- Web arayüzü: `https://your-domain.com`

### Zone-MTA SMTP Server
- Port: 587 (Submission)
- SSL Port: 465 (SMTPS)

### Haraka SMTP Server
- Port: 25 (SMTP)

### MongoDB Database
- Internal port: 27017
- Persistent storage ile

### Redis Cache
- Internal port: 6379
- Session ve cache için

## Monitoring ve Logs

Railway dashboard'da:
1. "Deployments" sekmesinde deployment durumunu kontrol edin
2. "Logs" sekmesinde uygulama loglarını görüntüleyin
3. "Metrics" sekmesinde performans metriklerini izleyin

## Troubleshooting

### Yaygın Sorunlar

1. **Port Erişim Sorunları**
   - Railway'de email portlarının açık olduğundan emin olun
   - Firewall ayarlarını kontrol edin

2. **Domain Yapılandırması**
   - DNS kayıtlarının doğru olduğundan emin olun
   - MX record'un doğru domain'i işaret ettiğini kontrol edin

3. **SSL Sertifika Sorunları**
   - Let's Encrypt rate limit'lerine takılmış olabilirsiniz
   - Domain validation'ın başarılı olduğundan emin olun

### Log Kontrolü

```bash
# Railway CLI ile logları görüntüleme
railway logs

# Belirli bir servisi takip etme
railway logs --follow
```

## Güvenlik

1. **Güçlü Şifreler**: Tüm database şifrelerini güçlü yapın
2. **Environment Variables**: Hassas bilgileri environment variable'larda saklayın
3. **SSL/TLS**: Production'da mutlaka SSL kullanın
4. **Firewall**: Gereksiz portları kapatın

## Backup

MongoDB verilerinizi düzenli olarak yedekleyin:
```bash
# MongoDB backup
mongodump --host mongodb-host --port 27017 --out backup/
```

## Destek

Sorun yaşarsanız:
1. Railway documentation'ı kontrol edin
2. WildDuck GitHub repository'sindeki issue'lara bakın
3. Railway Discord community'sine katılın

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.