# Uptime Kuma

Custom Slack notification provider for Docker deployment.

## Using a Custom Slack Notification Script

To use your custom Slack notification script in **Uptime Kuma**, mount the
JavaScript file into the running container via your
[`docker-compose.yml`](https://github.com/homelab-alpha/docker/blob/main/docker-compose-files/uptime-kuma/docker-compose.yml).
Add the following volume mapping under your service definition:

```yaml
volumes:
  - /docker/uptime-kuma/production/slack.js:/app/server/notification-providers/slack.js
```

## Notes

- Ensure the source path (`/docker/uptime-kuma/production/slack.js`) points to
  the actual location of your custom notification script.

- After updating your compose file, redeploy the container:

  ```bash
  docker compose up -d
  ```

- This override allows you to customize or extend Uptime Kuma’s Slack
  notification behavior without modifying the base container image.
