<?php

namespace App\Filament\Widgets;

use App\Enums\ResultStatus;
use App\Filament\Widgets\Concerns\HasChartFilters;
use App\Helpers\Average;
use App\Helpers\Number;
use App\Models\Result;
use Filament\Widgets\ChartWidget;

class RecentDownloadChartWidget extends ChartWidget
{
    use HasChartFilters;

    protected ?string $heading = 'Download (Mbps)';

    protected int|string|array $columnSpan = 'full';

    protected ?string $maxHeight = '250px';

    protected ?string $pollingInterval = '60s';

    public ?string $filter = null;

    public function mount(): void
    {
        config(['speedtest.default_chart_range' => '12h']);

        $this->filter = $this->filter ?? config('speedtest.default_chart_range');
    }

    protected function getData(): array
    {
        $fromDate = $this->getFilterDate($this->filter);

        $results = Result::query()
            ->select(['id', 'download', 'created_at'])
            ->where('status', ResultStatus::Completed)
            ->when(
                $fromDate,
                fn ($query) => $query->where('created_at', '>=', $fromDate)
            )
            ->orderBy('created_at')
            ->get();


        return [
            'datasets' => [
                // [
                //     'label' => 'Average',
                //     'order' => 2,
                //     'data' => array_fill(0, count($results), Average::averageDownload($results)),
                //     'borderColor' =>'rgba(243, 7, 6, 1)',
                //     'backgroundColor' => 'rgba(243, 7, 6, 0.1)',
                //     'pointBackgroundColor' => 'rgba(243, 7, 6, 1)',
                //     'fill' => false,
                //     'cubicInterpolationMode' => 'monotone',
                //     'tension' => 0.4,
                //     'pointRadius' => 0,
                // ],
                [
                    'label' => 'Download',
                    'order' => 1,
                    'data' => $results->map(fn ($item) =>
                        ! blank($item->download)
                            ? Number::bitsToMagnitude(
                                bits: $item->download_bits,
                                precision: 2,
                                magnitude: 'mbit'
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
            ],
            'labels' => $results->map(fn ($item) => $item->created_at->timezone(config('app.display_timezone'))->format(config('app.chart_datetime_format'))),
        ];
    }

    protected function getOptions(): array
    {
        return [
            'plugins' => [
                'legend' => [
                    'display' => false,

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
