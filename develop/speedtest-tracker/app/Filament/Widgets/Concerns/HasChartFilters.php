<?php

namespace App\Filament\Widgets\Concerns;

use Illuminate\Support\Carbon;

trait HasChartFilters
{
    /**
     * Central definition of all chart filters
     */
    protected function timeFilters(): array
    {
        return [
            // Minutes
            '5m'   => ['label' => 'Last 5 minutes',  'date' => now()->subMinutes(5)],
            '10m'  => ['label' => 'Last 10 minutes', 'date' => now()->subMinutes(10)],
            '15m'  => ['label' => 'Last 15 minutes', 'date' => now()->subMinutes(15)],
            '30m'  => ['label' => 'Last 30 minutes', 'date' => now()->subMinutes(30)],
            '45m'  => ['label' => 'Last 45 minutes', 'date' => now()->subMinutes(45)],

            // Hours
            '1h'   => ['label' => 'Last 1 hour',  'date' => now()->subHour()],
            '2h'   => ['label' => 'Last 2 hours', 'date' => now()->subHours(2)],
            '3h'   => ['label' => 'Last 3 hours', 'date' => now()->subHours(3)],
            '6h'   => ['label' => 'Last 6 hours', 'date' => now()->subHours(6)],
            '9h'   => ['label' => 'Last 9 hours','date'  => now()->subHours(9)],
            '12h'  => ['label' => 'Last 12 hours','date' => now()->subHours(12)],
            '15h'  => ['label' => 'Last 15 hours','date' => now()->subHours(15)],
            '18h'  => ['label' => 'Last 18 hours','date' => now()->subHours(18)],
            '21h'  => ['label' => 'Last 21 hours','date' => now()->subHours(21)],
            '24h'  => ['label' => 'Last 24 hours','date' => now()->subDay()],
            '36h'  => ['label' => 'Last 36 hours','date' => now()->subHours(36)],
            '48h'  => ['label' => 'Last 48 hours','date' => now()->subHours(48)],
            '72h'  => ['label' => 'Last 72 hours','date' => now()->subHours(72)],

            // Days
            '5d'   => ['label' => 'Last 5 days',  'date' => now()->subDays(5)],
            '7d'   => ['label' => 'Last 7 days',  'date' => now()->subDays(7)],
            '14d'  => ['label' => 'Last 14 days', 'date' => now()->subDays(14)],
            '28d'  => ['label' => 'Last 28 days', 'date' => now()->subDays(28)],
            '31d'  => ['label' => 'Last 31 days', 'date' => now()->subDays(31)],
            '45d'  => ['label' => 'Last 45 days', 'date' => now()->subDays(45)],
            '60d'  => ['label' => 'Last 60 days', 'date' => now()->subDays(60)],
            '90d'  => ['label' => 'Last 90 days', 'date' => now()->subDays(90)],
            '100d' => ['label' => 'Last 100 days','date' => now()->subDays(100)],
        ];
    }

    /**
     * Filament dropdown filters (labels)
     */
    protected function getFilters(): ?array
    {
        return collect($this->timeFilters())
            ->mapWithKeys(fn ($filter, $key) => [
                $key => $filter['label'],
            ])
            ->toArray();
    }

    /**
     * Returns the Carbon date for the active filter
     */
    protected function getFilterDate(?string $filter): ?Carbon
    {
        return $this->timeFilters()[$filter]['date'] ?? null;
    }
}
