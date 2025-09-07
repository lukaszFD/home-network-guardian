# Use a lightweight base image suitable for ARM64
FROM arm64v8/alpine:3.18

# Install dnsmasq
RUN apk update && \
    apk add dnsmasq && \
    rm -rf /var/cache/apk/*

# Expose port 53 for DNS
EXPOSE 53/udp

# Set the command to run dnsmasq with the config file
CMD ["dnsmasq", "-C", "/etc/dnsmasq.d/01-passive.conf", "-k"]