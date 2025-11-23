<?php

namespace App\Filament\Widgets\Concerns;

trait HasChartFilters
{
    /**
     * Get the available chart time range filters.
     *
     * @return array<string, string>|null
     */
    protected function getFilters(): ?array
    {
        return [
            // Minutes
            '1m'   => 'Last 1 minute',
            '2m'   => 'Last 2 minutes',
            '3m'   => 'Last 3 minutes',
            '4m'   => 'Last 4 minutes',
            '5m'   => 'Last 5 minutes',
            '10m'  => 'Last 10 minutes',
            '15m'  => 'Last 15 minutes',
            '30m'  => 'Last 30 minutes',
            '45m'  => 'Last 45 minutes',

            // Hours
            '1h'   => 'Last 1 hour',
            '2h'   => 'Last 2 hours',
            '3h'   => 'Last 3 hours',
            '6h'   => 'Last 6 hours',
            '12h'  => 'Last 12 hours',
            '24h'  => 'Last 24 hours',
            '36h'  => 'Last 36 hours',
            '48h'  => 'Last 48 hours',
            '72h'  => 'Last 72 hours',

            // Days
            '5d'   => 'Last 5 days',
            '7d'   => 'Last 7 days',
            '14d'  => 'Last 14 days',
            '28d'  => 'Last 28 days',
            '31d'  => 'Last 31 days',
            '45d'  => 'Last 45 days',
            '60d'  => 'Last 60 days',
            '90d'  => 'Last 90 days',
            '100d' => 'Last 100 days',
        ];
    }
}
