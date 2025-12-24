<?php

namespace App\Filament\Widgets;

use App\Enums\ResultStatus;
use App\Filament\Widgets\Concerns\HasChartFilters;
use App\Helpers\Average;
use App\Helpers\Number;
use App\Models\Result;
use Filament\Widgets\ChartWidget;

class RecentJitterChartWidget extends ChartWidget
{
    use HasChartFilters;

    protected ?string $heading = 'Jitter';

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
            ->select(['id', 'data', 'created_at'])
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
                    'label' => 'Download (ms)',
                    'order' => 1,
                    'data' => $results->map(fn ($item) =>
                        ! blank($item->download_jitter)
                            ? Number::bitsToMagnitude(
                                bits: $item->download_jitter,
                                precision: 2,
                                magnitude: 'ms'
                            )
                            : null
                    ),
                    'borderColor' => 'rgb(59, 130, 246)',
                    'backgroundColor' => 'rgba(59, 130, 246, 0.2)',
                    'pointBackgroundColor' => 'rgb(59, 130, 246)',
                    'fill' => false,
                    'cubicInterpolationMode' => 'monotone',
                    'tension' => 0.4,
                    'pointRadius' => 0,
                ],
                [
                    'label' => 'Ping (ms)',
                    'order' => 3,
                    'data' => $results->map(fn ($item) =>
                        ! blank($item->ping_jitter)
                            ? Number::bitsToMagnitude(
                                bits: $item->ping_jitter,
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
                [
                    'label' => 'Upload (ms)',
                    'order' => 2,
                    'data' => $results->map(fn ($item) =>
                        ! blank($item->upload_jitter)
                            ? Number::bitsToMagnitude(
                                bits: $item->upload_jitter,
                                precision: 2,
                                magnitude: 'ms'
                            )
                            : null
                    ),
                    'borderColor' => 'rgb(245, 158, 11)',
                    'backgroundColor' => 'rgba(245, 158, 11, 0.2)',
                    'pointBackgroundColor' => 'rgb(245, 158, 11)',
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
