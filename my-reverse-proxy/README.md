# My Reverse Proxy

Just a basic Nginx server that proxies traffic to the app- and webservers.

Currently building this by hand is not needed as Docker Compose builds the image from the path in `docker-compose.yml`.

In production it should use Let's Encrypt certificate with 90-day renewal crontab.

## Creating local SSL-certificate

To simulate production environment as much as possible this reverse proxy is configured to use a localhost certificate to secure the HTTP traffic over SSL. To build the image with the certificate you should first generate it with `./generate-key.sh local` to get the private and public keys. The command was copied from here: https://letsencrypt.org/docs/certificates-for-localhost/

You don't have to create your own dhparam-key as I've included pre-made one as I read from somewhere that it can be public. Also it takes like 20 minutes to create it.

After that you should then make your OS to trust your local certificate that I've only done with my macOS.

### Trusting the SSL certificate on any OS in Chrome

If you use this `chrome://flags/#allow-insecure-localhost` setting to Enabled you can probably avoid messing around with your System Settings completely. Which is pretty neat.

### Adding your SSL certificate to your trusted keys in macOS

Running `./trust-cert.sh macos` should it. If however it doesn't you can do it manually:

1) Open your Keychain Access app (Avainnippu in finnish) and this folder in Finder.
2) Drag and drop the `localhost.crt` to your Certificates > System keys. There should be already some keys there named `com.apple.systemdefault` etc.
3) Double click the added key and open the Trust Settings
4) Set the top most option to "Always Trust" (which should make all the lower ones Always Trust aswell)
5) That should do it, rebuild if you haven't done already with `docker-compose build` and open the app in https://localhost:9443

NOTE: Because of stuff, mainly because of the Strict-Transport-Security in the `nginx.conf`, Chrome tries to now send all requests to localhost through HTTPS. This is kinda awkward when developing other apps in your localhost... To disable it first remove the certificate from the Keychain. Then to do the same thing for Chrome go to `chrome://net-internals/#hsts` and input `localhost` to "Delete domain security policies" to delete it from Chrome's memory. Detailed instructions here https://stackoverflow.com/questions/25277457/google-chrome-redirecting-localhost-to-https.