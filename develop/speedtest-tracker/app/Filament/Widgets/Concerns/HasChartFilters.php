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
            // Real-time
            '5m' => [
                'label'  => 'Last 5 minutes',
                'date'   => now()->subMinutes(5),
                'format' => 'H:i',
            ],
            '15m' => [
                'label'  => 'Last 15 minutes',
                'date'   => now()->subMinutes(15),
                'format' => 'H:i',
            ],
            '30m' => [
                'label'  => 'Last 30 minutes',
                'date'   => now()->subMinutes(30),
                'format' => 'H:i',
            ],

            // Hours
            '1h' => [
                'label'  => 'Last 1 hour',
                'date'   => now()->subHour(),
                'format' => 'H:i',
            ],
            '3h' => [
                'label'  => 'Last 3 hours',
                'date'   => now()->subHours(3),
                'format' => 'H:i',
            ],
            '6h' => [
                'label'  => 'Last 6 hours',
                'date'   => now()->subHours(6),
                'format' => 'H:i',
            ],
            '12h' => [
                'label'  => 'Last 12 hours',
                'date'   => now()->subHours(12),
                'format' => 'H:i',
            ],
            '24h' => [
                'label'  => 'Last 24 hours',
                'date'   => now()->subDay(),
                'format' => 'D H:i',
            ],

            // Days
            '7d' => [
                'label'  => 'Last 7 days',
                'date'   => now()->subDays(7),
                'format' => 'D jS, H:i',
            ],
            '14d' => [
                'label'  => 'Last 14 days',
                'date'   => now()->subDays(14),
                'format' => 'D jS, H:i',
            ],
            '30d' => [
                'label'  => 'Last 30 days',
                'date'   => now()->subDays(30),
                'format' => 'M jS, H:i',
            ],

            // Long-term
            '90d' => [
                'label'  => 'Last 90 days',
                'date'   => now()->subDays(90),
                'format' => 'M jS, Y',
            ],
            '180d' => [
                'label'  => 'Last 180 days',
                'date'   => now()->subDays(180),
                'format' => 'M jS, Y',
            ],
            '365d' => [
                'label'  => 'Last 365 days',
                'date'   => now()->subDays(365),
                'format' => 'M jS, Y',
            ],
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

    /**
     * Returns the label format for the active filter
     */
    protected function getFilterLabelFormat(?string $filter): string
    {
        return $this->timeFilters()[$filter]['format']
            ?? 'M jS, Y, H:i';
    }
}
