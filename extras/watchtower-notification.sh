#!/bin/bash
# Watchtower is an application that will monitor your running Docker containers and watch for
# changes to the images that those containers were originally started from. If watchtower detects
# that an image has changed, it will automatically restart the container using the new image.

# This will install Watchtower with '--cleanup' '--schedule "0 */6 * * *"' agruments which
# removes old images and runs every 6hrs. You may edit the schedule if you wish.

# Check if Watchtower is installed and remove
watchtowercheck="watchtower"
if docker ps -a --format '{{.Names}}' | grep -Eq "^${watchtowercheck}\$"; then
    echo
    echo "Watchtower already installed, will uninstall..."
    docker stop watchtower && docker container rm watchtower
fi
docker run -d \
--name watchtower \
-v /var/run/docker.sock:/var/run/docker.sock \
-e WATCHTOWER_NOTIFICATIONS=email \
-e WATCHTOWER_NOTIFICATION_EMAIL_FROM=fromaddress@gmail.com \
-e WATCHTOWER_NOTIFICATION_EMAIL_TO=toaddress@gmail.com \
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER=smtp.gmail.com \
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_USER=fromaddress@gmail.com \
-e WATCHTOWER_NOTIFICATION_EMAIL_SERVER_PASSWORD=app_password \
-e WATCHTOWER_NOTIFICATION_EMAIL_DELAY=2 \
containrrr/watchtower \
--cleanup --schedule "0 */6 * * *"