# Radar dashboard

 We could use example from [Querying from Grafana](https://developers.cloudflare.com/analytics/analytics-engine/grafana/) to visuzlise collected data.

 1. Adjust *compose.yaml* file based on [Run Grafana Docker image](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/).

 2. Define variables
    ```shell
    export CLOUDFLARE_API_TOKEN="<api token>"
    export CLOUDFLARE_ANALYTICS_ENGINE_URL="https://api.cloudflare.com/client/v4/accounts/<account_id>/analytics_engine/sql"
    ```

 3. Run it and wait several minutes to provision defined resources
    ```shell
    docker compose up
    ```

 4. Open http://localhost:3000 to access the dashboard.
