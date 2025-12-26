# Speedtest Tracker

Custom Widgets for Docker Deployment

## Overview

Speedtest Tracker is a tool for tracking your internet speed and displaying the
data on a custom dashboard. This guide explains how to use custom PHP widgets
with Speedtest Tracker within a Docker environment.

## Using Custom PHP Widgets

To integrate your custom PHP widgets into **Speedtest Tracker**, you'll need to
mount the PHP widget files into the running Docker container. This can be done
by modifying your
[`docker-compose.yml`](https://github.com/homelab-alpha/docker/blob/main/docker-compose-files/speedtest-tracker/docker-compose.yml).

### Step-by-Step Instructions

1. **Modify your `docker-compose.yml` file**:

   Add the following volume mappings under your service definition. These
   mappings link your local widget files to the appropriate locations inside the
   container:

   ```yml
   volumes:
     - /docker/speedtest-tracker/app/Filament/Widgets/Concerns/HasChartFilters.php:/app/www/app/Filament/Widgets/Concerns/HasChartFilters.php
     - /docker/speedtest-tracker/app/Filament/Widgets/RecentDownloadChartWidget.php:/app/www/app/Filament/Widgets/RecentDownloadChartWidget.php
     - /docker/speedtest-tracker/app/Filament/Widgets/RecentDownloadLatencyChartWidget.php:/app/www/app/Filament/Widgets/RecentDownloadLatencyChartWidget.php
     - /docker/speedtest-tracker/app/Filament/Widgets/RecentJitterChartWidget.php:/app/www/app/Filament/Widgets/RecentJitterChartWidget.php
     - /docker/speedtest-tracker/app/Filament/Widgets/RecentPingChartWidget.php:/app/www/app/Filament/Widgets/RecentPingChartWidget.php
     - /docker/speedtest-tracker/app/Filament/Widgets/RecentUploadChartWidget.php:/app/www/app/Filament/Widgets/RecentUploadChartWidget.php
     - /docker/speedtest-tracker/app/Filament/Widgets/RecentUploadLatencyChartWidget.php:/app/www/app/Filament/Widgets/RecentUploadLatencyChartWidget.php
     - /docker/speedtest-tracker/resources/views/dashboard.blade.php:/app/www/resources/views/dashboard.blade.php
   ```

2. **Ensure Correct File Paths**: Make sure that the source paths
   (`/docker/speedtest-tracker/...`) match the actual location of your custom
   widget files on your system.

3. **Redeploy the Container**: After updating the `docker-compose.yml` file,
   redeploy your container with the following command:

   ```bash
   docker-compose up -d
   ```

   This will apply the changes and mount your custom widgets into the container.

<br />

> [!Note]
>
> - The volume mappings are necessary to customize or extend the Filament
>   dashboard widgets in Speedtest Tracker without modifying the base container
>   image.
