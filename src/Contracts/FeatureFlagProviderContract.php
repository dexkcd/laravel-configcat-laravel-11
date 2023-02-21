<?php

namespace PodPoint\ConfigCat\Contracts;

interface FeatureFlagProviderContract
{
    /**
     * @param string $key
     * @param mixed|null $user
     * @return bool|string|int
     */
    public function get(string $key, $user = null);

    /**
     * @param array $flagsToOverride
     * @return void
     */
    public function override(array $flagsToOverride);
}
