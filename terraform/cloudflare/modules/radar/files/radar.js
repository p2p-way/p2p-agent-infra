import { env } from "cloudflare:workers";

// Variables
const AUTH = env.AUTH;

export default {
  async fetch(request) {

    // Base
    let data = {};
    let status = 200;

    // Auth
    const url = new URL(request.url);
    const Auth = url.searchParams.get("auth");
    if (AUTH != null && Auth != AUTH) {
      data = {"Auth": "Failed"};
      status = 401;
    } else {
      // Agent metadata - Index
      let headersObject = Object.fromEntries(request.headers);
      const PublicIp = headersObject["cf-connecting-ip"];

      // Agent metadata - Blobs
      const Colo = request.cf.colo;
      const Asn = request.cf.asn;
      const AsOrganization = request.cf.asOrganization;
      const Country = request.cf.country;
      const City = request.cf.city;
      const Region = request.cf.region;
      const RegionCode = request.cf.regionCode
      const Continent = request.cf.continent;
      const Latitude = request.cf.latitude;
      const Longitude = request.cf.longitude;

      // Agent data - Blobs
      const Cloud = url.searchParams.get("cloud") || "unknown";
      const CloudRegion = url.searchParams.get("region") || "unknown";
      const Autoscaler = url.searchParams.get("autoscaler") || "unknown";
      const Services = url.searchParams.get("services") || "unknown";
      const Capacity = url.searchParams.get("capacity") || -1;
      const Uptime = url.searchParams.get("uptime") || -1;
      const Duration = url.searchParams.get("duration") || -1;

      // Agent data - Doubles
      const Count = 1;

      // Debug
      // const PublicIp = url.searchParams.get("ip") || headersObject["cf-connecting-ip"];
      data.cf = request.cf;
      data.url = request.url;
      data.method = request.method
      data.path = request.path
      data.radar = {}
      data.radar.Cloud = Cloud
      data.radar.Region = CloudRegion
      data.radar.Autoscaler = Autoscaler
      data.radar.Services = Services
      data.radar.Duration = Duration
      data.radar.Uptime = Uptime
      data.radar.PublicIp = PublicIp

      // Cloud  -->  Network  -->  Location
      env.ANALYTICS_DATASET.writeDataPoint({
        blobs: [
          Cloud,
          CloudRegion,
          Autoscaler,
          Services,
          Colo,
          Asn,
          AsOrganization,
          Continent,
          Country,
          RegionCode,
          Region,
          City,
          Latitude,
          Longitude
        ],
        doubles: [Count, Capacity, Duration, Uptime],
        indexes: [PublicIp],
      });
    }

    // Response
    return new Response(JSON.stringify(data, null, 2), {
      status: status,
      headers: {
        "content-type": "application/json;charset=UTF-8",
      },
    });
  },
};
