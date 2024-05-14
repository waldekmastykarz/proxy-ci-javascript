# enable job control so that we can send SIGINT to Dev Proxy
set -m

echo "Starting Dev Proxy..."

# start Dev Proxy with recording
# redirect all output to a log file
./devproxy/devproxy-beta --record > $LOG_FILE 2>&1 &

proxy_pid=$!

# wait for init
echo "Waiting for Dev Proxy to start..."
while true; do
  if grep -q "Recording" $LOG_FILE; then
    break
  fi
  sleep 1
done

# From: https://www.eliostruyf.com/playwright-microsoft-dev-proxy-github-actions/
# setup certificates
echo "Export the Dev Proxy's Root Certificate"
openssl pkcs12 -in ~/.config/dev-proxy/rootCert.pfx -clcerts -nokeys -out dev-proxy-ca.crt -passin pass:""

echo "Installing certutil..."
sudo apt install libnss3-tools

echo "Adding certificate to the NSS database for Chromium..."
mkdir -p $HOME/.pki/nssdb
certutil --empty-password -d $HOME/.pki/nssdb -N 
certutil -d sql:$HOME/.pki/nssdb -A -t "CT,," -n dev-proxy-ca.crt -i dev-proxy-ca.crt
echo "Certificate trusted." 

echo "Running Playwright tests..."
npm run test:versioned

# send SIGINT to Dev Proxy to close it gracefully
echo "Stopping Dev Proxy..."
kill -INT $proxy_pid

echo "Waiting for Dev Proxy to complete..."
while true; do
  if grep -q -e "^DONE$" -e "No requests to process" -e "An error occurred in a plugin" $LOG_FILE; then
    break
  fi
  sleep 1
done
