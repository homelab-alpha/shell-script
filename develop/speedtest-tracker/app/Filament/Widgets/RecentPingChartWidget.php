<?php

namespace App\Filament\Widgets;

use App\Enums\ResultStatus;
use App\Filament\Widgets\Concerns\HasChartFilters;
use App\Helpers\Average;
use App\Models\Result;
use Filament\Widgets\ChartWidget;

class RecentPingChartWidget extends ChartWidget
{
    use HasChartFilters;

    protected ?string $heading = 'Ping (ms)';

    protected int|string|array $columnSpan = 'full';

    protected ?string $maxHeight = '250px';

    protected ?string $pollingInterval = '60s';

    public ?string $filter = null;

    public function mount(): void
    {
        config(['speedtest.default_chart_range' => '24h']);

        $this->filter = $this->filter ?? config('speedtest.default_chart_range');
    }

    protected function getData(): array
    {
        $timeFilters = [
            // Minutes
            '5m'   => now()->subMinutes(5),
            '10m'  => now()->subMinutes(10),
            '15m'  => now()->subMinutes(15),
            '30m'  => now()->subMinutes(30),
            '45m'  => now()->subMinutes(45),

            // Hours
            '1h'   => now()->subHour(),
            '2h'   => now()->subHours(2),
            '3h'   => now()->subHours(3),
            '6h'   => now()->subHours(6),
            '12h'  => now()->subHours(12),
            '18h'  => now()->subHours(18),
            '24h'  => now()->subDay(),
            '36h'  => now()->subHours(36),
            '48h'  => now()->subHours(48),
            '72h'  => now()->subHours(72),

            // Days
            '5d'   => now()->subDays(5),
            '7d'   => now()->subDays(7),
            '14d'  => now()->subDays(14),
            '28d'  => now()->subDays(28),
            '31d'  => now()->subDays(31),
            '45d'  => now()->subDays(45),
            '60d'  => now()->subDays(60),
            '90d'  => now()->subDays(90),
            '100d' => now()->subDays(100),
        ];

        $results = Result::query()
            ->select(['id', 'ping', 'created_at'])
            ->where('status', ResultStatus::Completed)
            ->when(
                isset($timeFilters[$this->filter]),
                fn($query) => $query->where('created_at', '>=', $timeFilters[$this->filter])
            )
            ->orderBy('created_at')
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Average',
                    'order' => 2,
                    'data' => array_fill(0, count($results), Average::averagePing($results)),
                    'borderColor' => 'rgba(243, 7, 6, 1)',
                    'backgroundColor' => 'rgba(243, 7, 6, 0.1)',
                    'pointBackgroundColor' => 'rgba(243, 7, 6, 1)',
                    'fill' => false,
                    'cubicInterpolationMode' => 'monotone',
                    'tension' => 0.4,
                    'pointRadius' => 0,
                    // 'showLine' => false,
                ],
                [
                    'label' => 'Ping',
                    'order' => 1,
                    'data' => $results->map(fn ($item) => $item->ping),
                    'borderColor' => 'rgba(139, 92, 246, 1)',
                    'backgroundColor' => 'rgba(139, 92, 246, 0.1)',
                    'pointBackgroundColor' => 'rgba(139, 92, 246, 1)',
                    'fill' => true,
                    'cubicInterpolationMode' => 'monotone',
                    'tension' => 0.4,
                    'pointRadius' => count($results) <= 24 ? 3 : 0,
                ],
            ],
            'labels' => $results->map(fn ($item) => $item->created_at->timezone(config('app.display_timezone'))->format(config('app.chart_datetime_format'))),
        ];
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => true,
                ],
                'tooltip' => [
                    'enabled' => true,
                    'mode' => 'index',
                    'intersect' => false,
                    'position' => 'nearest',
                ],
            ],
            'scales' => [
                'y' => [
                    'beginAtZero' => config('app.chart_begin_at_zero'),
                    'grace' => 2,
                ],
            ],
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
