variable "ssh_public_keys" {
  type        = list(string)
  description = "SSH public keys authorized to access the VM cluster. Supply the public key contents, not file paths."
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
