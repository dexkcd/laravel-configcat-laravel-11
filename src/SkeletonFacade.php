<?php

namespace PodPoint\Skeleton;

use Illuminate\Support\Facades\Facade;

/**
 * @see \PodPoint\Skeleton\Skeleton
 */
class SkeletonFacade extends Facade
{
    protected static function getFacadeAccessor()
    {
        return ':package_key';
    }
}
