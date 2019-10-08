defmodule Civo.Quota do
  @moduledoc """
  Our quotas (and therefore our pricing), are based on a 
  combined allocation of CPU, RAM and disk. All customers 
  start on a basic quota level and after a period of proving 
  that the quota is being handled correctly or after a call 
  to our offices, we can increase this quota.
  """
  @doc """
  Gets the quota of an account.

  ### Request
  This request doesn't require any parameters passing in.

  ### Response
  The response from the server will be a JSON object 
  describing the current quota limits and usage:

  ```elixir
  {
    "id": "44aab548-61ca-11e5-860e-5cf9389be614",
    "default_user_id": "ca04ddda-06e1-469a-ad63-27ac3298c42c",
    "default_user_email_address": "johnsmith@example.com",
    "instance_count_limit": 16,
    "instance_count_usage": 6,
    "cpu_core_limit": 10,
    "cpu_core_usage": 3,
    "ram_mb_limit": 5120,
    "ram_mb_usage": 1536,
    "disk_gb_limit": 250,
    "disk_gb_usage": 75,
    "disk_volume_count_limit": 16,
    "disk_volume_count_usage": 6,
    "disk_snapshot_count_limit": 30,
    "disk_snapshot_count_usage": 0,
    "public_ip_address_limit": 16,
    "public_ip_address_usage": 6,
    "subnet_count_limit": 10,
    "subnet_count_usage": 1,
    "network_count_limit": 10,
    "network_count_usage": 1,
    "security_group_limit": 16,
    "security_group_usage": 5,
    "security_group_rule_limit": 160,
    "security_group_rule_usage": 24,
    "port_count_limit": 32,
    "port_count_usage": 7
  }
  ```
  """
  @spec get() :: Civo.Response.t() | Civo.Error.t()
  def get(),
    do: Civo.get("quota")
end
