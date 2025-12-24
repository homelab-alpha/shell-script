<x-app-layout title="Metrics Dashboard">
    <div class="space-y-6 md:space-y-12 dashboard-page">

        <livewire:latest-result-stats />

            @livewire(\App\Filament\Widgets\RecentDownloadChartWidget::class)

            @livewire(\App\Filament\Widgets\RecentUploadChartWidget::class)

            @livewire(\App\Filament\Widgets\RecentPingChartWidget::class)

            @livewire(\App\Filament\Widgets\RecentDownloadLatencyChartWidget::class)

            @livewire(\App\Filament\Widgets\RecentUploadLatencyChartWidget::class)

            @livewire(\App\Filament\Widgets\RecentJitterChartWidget::class)

        </div>
    </div>
</x-app-layout>
