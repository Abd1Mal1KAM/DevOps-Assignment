variable "accepted_protocols" {
  description = "ENUM for inbound_protocol and outbound_protocol"

  default = ["tcp", "udp", "icmp", "icmpv6", "-1"]
  type    = list(string)

# We validate only the AWS‑documented named protocols (tcp, udp, icmp, icmpv6, -1) because the Streamlit EC2 deployment does not require any numeric IANA protocols. Restricting to these values reduces attack surface, simplifies configuration, and aligns with the IpPermission API specification.

}
