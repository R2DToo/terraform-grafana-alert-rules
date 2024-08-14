module "grafana_alerts" {
  source = "./module"

  name        = "Node Monitors"
  folder_name = "Homelab"
  alert_rules = [
    {
      name        = "Node disk available"
      summary     = "{{$labels.cluster}}/{{$labels.instance}} Disk ({{$labels.mountpoint}}) out of space"
      query       = "node_filesystem_avail_bytes/node_filesystem_size_bytes < 0.2"
      window      = "15m"
      description = "Node {{$labels.instance}} mountpoint {{$labels.mountpoint}} is out of space, consider removing some files or adding more space"
    },
    {
      name        = "Node CPU usage"
      summary     = "{{$labels.cluster}}/{{$labels.instance}} Node CPU usage"
      query       = "sum(node_cpu_seconds_total{mode=\"idle\"}) by(cluster,instance)/sum(node_cpu_seconds_total{}) by(cluster,instance) < 0.8"
      window      = "15m"
      description = "Node {{$labels.instance}} is using more than 80% of the CPU for the last 15 minutes"
    },
    {
      name        = "Node Memory usage"
      summary     = "{{$labels.cluster}}/{{$labels.instance}} Node Memory usage"
      query       = "node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes"
      query       = "1 - avg by(instance,cluster) ((node_memory_MemFree_bytes{} + (node_memory_Cached_bytes{} + node_memory_Buffers_bytes{} + node_memory_SReclaimable_bytes{})) / node_memory_MemTotal_bytes{}) > 0.8"
      window      = "15m"
      description = "Node {{$labels.instance}} is using more than 80% of the Memory for the last 15 minutes"
    }
  ]
}