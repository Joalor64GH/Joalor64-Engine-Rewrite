module.exports = async ({github, context}, cacheKey) => {
    try {
        const caches = await github.rest.actions.getActionsCacheList({
            owner: context.repo.owner,
            repo: context.repo.repo,
        });

        let cacheFound = false;

        for (const cache of caches.data.actions_caches) {
            if (cache.key === cacheKey) {
                console.log(`Clearing ${cache.key}...`);

                await github.rest.actions.deleteActionsCacheById({
                    owner: context.repo.owner,
                    repo: context.repo.repo,
                    cache_id: cache.id,
                });

                console.log(`Previous Cache Cleared!`);
                cacheFound = true;
                break;
            }
        }

        if (!cacheFound) {
            console.log(`Cache key not found: ${cacheKey}`);
        }
    } catch (error) {
        console.log(error.message);
    }
};