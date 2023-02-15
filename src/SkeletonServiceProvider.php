<?php

namespace PodPoint\Skeleton;

use Illuminate\Support\ServiceProvider;

class SkeletonServiceProvider extends ServiceProvider
{
    /**
     * Register the service provider.
     *
     * @return void
     */
    public function register()
    {
        $this->mergeConfigFrom(__DIR__ . '/../config/:package_key.php', ':package_key');
    }

    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        if ($this->app->runningInConsole()) {
            $this->publishes([
                __DIR__ . '/../config/:package_key.php' => config_path(':package_key.php'),
            ]);
        }
    }
}
