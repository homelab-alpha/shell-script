# Speedtest Tracker

Custom Widgets for Docker deployment.

## Using Custom PHP Widgets

To use your custom widgets in **Speedtest Tracker**, mount the PHP files into
the running container via your
[`docker-compose.yml`](https://github.com/homelab-alpha/docker/blob/main/docker-compose-files/speedtest-tracker/docker-compose.yml).
Add the following volume mappings under your service definition:

```yaml
volumes:
  - /docker/speedtest-tracker/production/dashboard.blade.php:/app/www/resources/views/dashboard.blade.php
  - /docker/speedtest-tracker/production/HasChartFilters.php:/app/www/app/Filament/Widgets/Concerns/HasChartFilters.php
  - /docker/speedtest-tracker/production/RecentDownloadChartWidget.php:/app/www/app/Filament/Widgets/RecentDownloadChartWidget.php
  - /docker/speedtest-tracker/production/RecentDownloadLatencyChartWidget.php:/app/www/app/Filament/Widgets/RecentDownloadLatencyChartWidget.php
  - /docker/speedtest-tracker/production/RecentJitterChartWidget.php:/app/www/app/Filament/Widgets/RecentJitterChartWidget.php
  - /docker/speedtest-tracker/production/RecentPingChartWidget.php:/app/www/app/Filament/Widgets/RecentPingChartWidget.php
  - /docker/speedtest-tracker/production/RecentUploadChartWidget.php:/app/www/app/Filament/Widgets/RecentUploadChartWidget.php
  - /docker/speedtest-tracker/production/RecentUploadLatencyChartWidget.php:/app/www/app/Filament/Widgets/RecentUploadLatencyChartWidget.php
```

## Notes

- Ensure the source paths (`/docker/speedtest-tracker/production/...`) point to
  the real location of your custom widget files.
- After updating the compose file, redeploy the container:

  ```bash
  docker compose up -d
  ```

- These overrides allow you to customize or extend the Filament dashboard
  widgets used by Speedtest Tracker—without modifying the base container image.
