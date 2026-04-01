# Color sequence memory

Memorize the sequence, then repeat it.

## Special installation notes

### Ubuntu users

In order to install the deb file, you may want to activate the universe repository

```bash
sudo add-apt-repository universe
```

then

```bash
sudo apt install ./chess_exercises_notes-vx.x.x.deb
```

where you replace x.x.x with the package version.

## For developpers

### Linux users

The audio dependency needs the ALSA development headers. So if you're a Debian-based system

```
sudo apt-get install -y libasound2-dev
```

### Android signing keystore

The release APK/AAB must be signed with a personal keystore. This keystore and its credentials file (`key.properties`) are **never committed to git**.

**1. Generate the keystore**

Generate keystore from terminal and set it in folder `android/app`
(replace relevant parts accordingly)

```
keytool -genkeypair -v \
  -keystore android/app/production-release.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 11000
```

**2. Create `android/key.properties`** with the following content (replace values accordingly):

```properties
storePassword=<store password>
keyPassword=<key password>
keyAlias=<key-alias>
storeFile=<keystore-name.jks>
```

Both `android/key.properties` and `android/app/<keystore-name>.jks` are already listed in `android/.gitignore` and will not be published.

**3. GitHub Actions secrets**

The CI workflow reconstructs the keystore and `key.properties` from repository secrets. Add the following secrets in **GitHub → Settings → Secrets and variables → Actions**:

| Secret name               | Value                                                                  |
| ------------------------- | ---------------------------------------------------------------------- |
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore (`base64 -w0 android/app/<keystore-name>.jks`) |
| `ANDROID_STORE_PASSWORD`  | Store password                                                         |
| `ANDROID_KEY_PASSWORD`    | Key password                                                           |
| `ANDROID_KEY_ALIAS`       | Key alias                                                              |

Generate the base64 value with:

```bash
base64 -w0 android/app/<keystore-name>.jks
```
