<?php

namespace App\Filament\Widgets;

use App\Enums\ResultStatus;
use App\Filament\Widgets\Concerns\HasChartFilters;
use App\Helpers\Average;
use App\Helpers\Number;
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

        $this->filter = $this->filter
            ?? config('speedtest.default_chart_range');
    }

    protected function getData(): array
    {
        // Get the filter date and its associated time format
        $fromDate    = $this->getFilterDate($this->filter);
        $labelFormat = $this->getFilterLabelFormat($this->filter);

        // Get the results
        $results = Result::query()
            ->select(['id', 'ping', 'created_at'])
            ->where('status', ResultStatus::Completed)
            ->when(
                $fromDate,
                fn ($query) => $query->where('created_at', '>=', $fromDate)
            )
            ->orderBy('created_at')
            ->get();

        // Return the data for the chart
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
                ],
                [
                    'label' => 'Ping',
                    'order' => 1,
                    'data' => $results->map(fn ($item) =>
                        ! blank($item->ping)
                            ? Number::bitsToMagnitude(
                                bits: $item->ping,
                                precision: 2,
                                magnitude: 'ms'
                            )
                            : null
                    ),
                    'borderColor' => 'rgb(168, 85, 247)',
                    'backgroundColor' => 'rgba(168, 85, 247, 0.2)',
                    'pointBackgroundColor' => 'rgb(168, 85, 247)',
                    'fill' => false,
                    'cubicInterpolationMode' => 'monotone',
                    'tension' => 0.4,
                    'pointRadius' => 0,
                ],
            ],

            // Adjust labels based on filter format
            'labels' => $results->map(fn ($item) =>
                $item->created_at
                    ->timezone(config('app.display_timezone'))
                    ->format($labelFormat)
            ),
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
