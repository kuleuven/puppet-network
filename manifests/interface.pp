#
# = Define: network::interface
#
# This define manages interfaces.
# Currently only Debian and RedHat families supported.
# Some parameters are supported only for specific families
#
# == Common parameters
#
# $enable_dhcp
#   Boolean. Default: false
#   Activates DHCP on the interface
#
# [*ipaddress*]
# [*netmask*]
# [*broadcast*]
#   String. Default: undef
#   Standard network parameters
#
# [*hwaddr*]
#   String. Default: undef
#   - On RedHat: assigns this interface name to the device with this mac.
#   - On Debian/Suse: spoofs mac address of the interface.
#     (syntax may be broke on Debian. if so, try $macaddr).
#   Do not use togehter with $macaddr.
#
# [*macaddr*]
#   String. Default: undef
#   Spoofs mac address of the interface.
#   Do not use together with $hwaddr.
#
# [*enable*]
#   Boolean. Default: true
#   Manages the interface presence. Possible values:
#   * true   - Interface created and enabled at boot.
#   * false  - Interface removed from boot.
#
# [*template*]
#   String. Optional. Default: Managed by module.
#   Provide an alternative custom template to use for configuration of:
#   - On Debian: file fragments in /etc/network/interfaces
#   - On RedHat: files /etc/sysconfig/network-scripts/ifcfg-${name}
#   You can copy and adapt network/templates/interface/$facts['os']['family'].erb
#
# [*restart_all_nic*]
#   Boolean. Default: true
#   Manages the way to apply interface creation/modification:
#   - If true, will trigger a restart of all network interfaces
#   - If false, will only start/restart this specific interface
#
# [*reload_command*]
#   String. Default: $facts['os']['name'] ? {'CumulusLinux' => 'ifreload -a',
#                                          default        => "ifdown ${interface}; ifup ${interface}",
#                                         }
#   Defines the command(s) that will be used to reload a nic when restart_all_nic
#   is set to false
#
# [*options*]
#   A generic hash of custom options that can be used in a custom template
#
# [*options_extra_redhat*]
# [*options_extra_debian*]
# [*options_extra_suse*]
#   Custom hashes of options that are added to the default template that manages
#   interfaces respectively under RedHat, Debian and Suse families
#
# [*description*]
#   String. Optional. Default: undef
#   Adds comment with given description in file before interface declaration.
#
# == Debian only parameters
#
#  $address       = undef,
#    Both ipaddress (standard name) and address (Debian param name) if set
#    configure the ipv4 address of the interface.
#    If both are present address is used.
#    Note, that if $my_inner_ipaddr (for GRE) is set - it is used instead.
#
#  $manage_order  = 10,
#    This is used by concat to define the order of your fragments,
#    can be used to load an interface before another.
#    default it's 10.
#
#  $method        = '',
#    Both enable_dhcp (standard) and method (Debian specific param name) if set
#    configure dhcp on the interface via the method setting.
#    If both are present method is used.
#
#  $up            = [ ],
#  $pre_up        = [ ],
#  $post_up        = [ ],
#  $down          = [ ],
#  $pre_down      = [ ],
#  $post_down      = [ ],
#    Map to Debian interfaces parameters (with _ instead of -)
#    Note that these params MUST be arrays, even if with only one element
#
#  $nonlocal_gateway = undef,
#    Gateway, that does not belong to interface's network and needs extra
#    route to be available. Shortcut for:
#
#      post-up ip route add $nonlocal_gateway dev $interface
#      post-up ip route add default via $nonlocal_gateway dev $interface
#      pre-down ip route del default via $nonlocal_gateway dev $interface
#      pre-down ip route del $nonlocal_gateway dev $interface
#
#  $additional_networks = [],
#    Convenience shortcut to add more networks to the interface. Expands to:
#
#      up ip addr add $network dev $interface
#      down ip addr del $network dev $interface
#
# Check the arguments in the code for the other Debian specific settings
# If defined they are set in the used template.
#
# == RedHat only parameters
#
#  $type          = 'Ethernet',
#    Defaults to 'Ethernet', but following types are supported for OVS:
#    "OVSPort", "OVSIntPort", "OVSBond", "OVSTunnel" and "OVSPatchPort".
#    'InfiniBand' type is supported as well.
#
#  $ipaddr        = undef,
#    Both ipaddress (standard name) and ipaddr (RedHat param name) if set
#    configure the ipv4 address of the interface.
#    If both are present ipaddr is used.
#
#  $prefix        = undef,
#    Network PREFIX aka CIDR notation of the network mask. The PREFIX
#    takes precedence if both PREFIX and NETMASK are set.
#
#  $bootproto        = '',
#    Both enable_dhcp (standard) and bootproto (Debian specific param name),
#    if set, configure dhcp on the interface via the bootproto setting.
#    If both are present bootproto is used.
#
#  $arpcheck      = undef
#    Whether the interface will check if the supplied IP address is already in
#    use. Valid values are undef, "yes", "no".
#
#  $arp           = undef
#    Used to enable or disable ARP completely for an interface at initialization
#    Valid values are undef, "yes", "no".
#
#  $nozeroconf    = undef
#    Used to enable or disable ZEROCONF routes completely for an
#    interface at initialization
#    Valid values are undef, "yes, 'no".
#
#  $linkdelay     = undef
#    Used to introduce a delay (sleep) of the specified number of seconds when
#    bringing an interface up.
#
#  $check_link_down = false
#    Set to true to add check_link_down function in the interface file
#
#  $hotswap = undef
#    Set to no to prevent interface from being activated when hot swapped - Default is yes
#
#  $vid = undef
#    Set to specify vlan id #
#
# == RedHat and Debian only GRE interface specific parameters
#
#  $peer_outer_ipaddr = undef
#    IP address of the remote tunnel endpoint
#
#  $peer_inner_ipaddr = undef
#    IP address of the remote end of the tunnel interface. If this is specified,
#    a route to PEER_INNER_IPADDR through the tunnel is added automatically.
#
#  $my_outer_ipaddr   = undef
#    IP address of the local tunnel endpoint. If unspecified, an IP address
#    is selected automatically for outgoing tunnel packets, and incoming tunnel
#    packets are accepted on all local IP addresses.
#
#  $my_inner_ipaddr   = undef
#    Local IP address of the tunnel interface.
#
# == RedHat only Open vSwitch specific parameters
#
#  $devicetype      = undef,
#    Always set to "ovs" if configuring OVS* type.
#
#  $bond_ifaces     = undef,
#    Physical interfaces for "OVSBond".
#
#  $ovs_bridge      = undef,
#    For types other than "OVSBridge" type. It specifies the OVS bridge
#    to which port, patch or tunnel should be attached to.
#
#  $ovs_ports       = undef,
#    It specifies the OVS ports should OVS bridge attach
#
#  $ovs_extra       = undef,
#    Optional: extra ovs-vsctl commands seperate by "--" (double dash)
#
#  $ovs_options     = undef,
#    Optional: extra options to set in the Port table.
#    Check ovs-vsctl's add-port man page.
#
#  $ovs_patch_peer  = undef,
#    Patche's peer on the other bridge for "OVSPatchPort" type.
#
#  $ovs_tunnel_type = undef,
#    Tunnel types (eg. "vxlan", "gre") for "OVSTunnel" type.
#
#  $ovs_tunnel_options = undef,
#    Tunnel options (eg. "remote_ip") for "OVSTunnel" type.
#
#  $ovsdhcpinterfaces = undef,
#    All the interfaces that can reach the DHCP server as a space separated list
#
#  $ovsbootproto = undef,
#    Needs OVSBOOTPROTO instead of BOOTPROTO to enable DHCP on the bridge
#
# Check the arguments in the code for the other RedHat specific settings
# If defined they are set in the used template.
#
# == RedHat only InfiniBand specific parameters
#
#  $connected_mode = undef,
#     Enable or not InfiniBand CONNECTED_MODE. It true, CONNECTED_MODE=yes will
#     be added to ifcfg file.
#
# == Suse and Debian only parameters
#
#  $aliases = undef
#     Array of aliased IPs for given interface.
#     Note, that for Debian generated interfaces will have static method and
#     netmask 255.255.255.255.  If you need something other - generate
#     interfaces by hand.  Also note, that interfaces will be named
#     $interface:$idx, where $idx is IP index in list, starting from 0.
#     If you're adding manual interfaces - beware of clashes.
#
# == Suse only parameters
#
# Check the arguments in the code for the other Suse specific settings
# If defined they are set in the used template.
#
#
# == Red Hat zLinux on IBM ZVM/System Z (s390/s390x) only parameters
#
#  $subchannels = undef,
#     The hardware addresses of QETH or Hipersocket hardware.
#
#  $nettype = undef,
#     The networking hardware type.  qeth, lcs or ctc.
#     The default is 'qeth'.
#
#  $layer2 = undef,
#     The networking layer mode in Red Hat 6. 0 or 1.
#     The defauly is 0. From Red Hat 7 this is confifured using the options
#     parameter below.
#
#  $zlinux_options = undef
#     You can add any valid sysfs attribute and its value to the OPTIONS
#     parameter.The Red Hat Enterprise Linux (7 )installation program currently
#     uses this to configure the layer mode (layer2) and the relative port
#     number (portno) of qeth devices.
#
# @example Configure a vlan interface:
#
#    network::interface { 'ens18.252':
#      method          => 'static',
#      ipaddress       => '10.10.10.10',
#      netmask         => '255.255.255.0',
#      type            => 'vlan',
#    }
#
define network::interface (

  Boolean $enable                = true,
  Enum['present','absent'] $ensure                = 'present',
  String $template              = "network/interface/${facts['os']['family']}.erb",
  Optional[Hash] $options               = undef,
  Optional[Hash] $options_extra_redhat  = undef,
  Optional[Hash] $options_extra_debian  = undef,
  Optional[Hash] $options_extra_suse    = undef,
  String $interface             = $name,
  Boolean $restart_all_nic = $facts['os']['family'] ? {
    'RedHat' => $facts['os']['release']['major'] ? {
      '8'     => false,
      default => true,
    },
    default  => true,
  },
  Optional[String] $reload_command        = undef,

  Boolean $enable_dhcp           = false,

  $ipaddress             = '',
  $netmask               = undef,
  $network               = undef,
  $broadcast             = undef,
  $gateway               = undef,
  $hwaddr                = undef,
  $macaddr               = undef,
  $mtu                   = undef,

  $description           = undef,

  ## Debian specific
  $manage_order          = '10',
  Boolean $auto                  = true,
  $allow_hotplug         = undef,
  $method                = '',
  $family                = 'inet',
  $stanza                = 'iface',
  $address               = '',
  $dns_search            = undef,
  $dns_nameservers       = undef,
  # For method: static
  $metric                = undef,
  $pointopoint           = undef,

  # For method: dhcp
  $hostname              = undef,
  $leasehours            = undef,
  $leasetime             = undef,
  $client                = undef,

  # For method: bootp
  $bootfile              = undef,
  $server                = undef,

  # For method: tunnel
  $mode                  = undef,
  $endpoint              = undef,
  $dstaddr               = undef,
  $local                 = undef,
  $ttl                   = undef,

  # For method: ppp
  $provider              = undef,
  $unit                  = undef,

  # For inet6 family
  $privext               = undef,
  $dhcp                  = undef,
  $media                 = undef,
  $accept_ra             = undef,
  $autoconf              = undef,
  $vlan_raw_device       = undef,

  # Convenience shortcuts
  $nonlocal_gateway      = undef,
  Array $additional_networks   = [ ],

  # Common ifupdown scripts
  Array $up                    = [ ],
  Array $pre_up                = [ ],
  Array $post_up               = [ ],
  Array $down                  = [ ],
  Array $pre_down              = [ ],
  Array $post_down             = [ ],

  # For virtual routing and forwarding (VRF)
  $vrf                   = undef,
  $vrf_table             = undef,

  # For bonding
  Array $slaves                = [ ],
  $bond_mode             = undef,
  $bond_miimon           = undef,
  $bond_downdelay        = undef,
  $bond_updelay          = undef,
  $bond_lacp_rate        = undef,
  $bond_master           = undef,
  $bond_primary          = undef,
  Array $bond_slaves           = [ ],
  $bond_xmit_hash_policy = undef,
  $bond_num_grat_arp     = undef,
  $bond_arp_all          = undef,
  $bond_arp_interval     = undef,
  $bond_arp_iptarget     = undef,
  $bond_fail_over_mac    = undef,
  $bond_ad_select        = undef,
  $use_carrier           = undef,
  $primary_reselect      = undef,

  # For teaming
  $team_config           = undef,
  $team_port_config      = undef,
  $team_master           = undef,

  # For bridging
  Array $bridge_ports          = [ ],
  $bridge_stp            = undef,
  $bridge_fd             = undef,
  $bridge_maxwait        = undef,
  $bridge_waitport       = undef,

  # For wpa_supplicant
  $wpa_ssid              = undef,
  $wpa_bssid             = undef,
  $wpa_psk               = undef,
  Array $wpa_key_mgmt          = [ ],
  Array $wpa_group             = [ ],
  Array $wpa_pairwise          = [ ],
  Array $wpa_auth_alg          = [ ],
  Array $wpa_proto             = [ ],
  $wpa_identity          = undef,
  $wpa_password          = undef,
  $wpa_scan_ssid         = undef,
  $wpa_ap_scan           = undef,

  ## RedHat specific
  $ipaddr                = '',
  $prefix                = undef,
  $uuid                  = undef,
  $bootproto             = '',
  $userctl               = 'no',
  $type                  = 'Ethernet',
  $ethtool_opts          = undef,
  $ipv6init              = undef,
  $ipv6_autoconf         = undef,
  $ipv6_privacy          = undef,
  $ipv6_addr_gen_mode    = undef,
  $ipv6addr              = undef,
  $ipv6addr_secondaries  = [],
  $ipv6_defaultgw        = undef,
  $ipv6_failure_fatal    = undef,
  $dhcp_hostname         = undef,
  $srcaddr               = undef,
  $peerdns               = '',
  $peerntp               = '',
  $onboot                = '',
  $onparent              = undef,
  $defroute              = undef,
  $dns1                  = undef,
  $dns2                  = undef,
  $dns3                  = undef,
  $domain                = undef,
  $nm_controlled         = undef,
  $master                = undef,
  $slave                 = undef,
  $bonding_master        = undef,
  $bonding_opts          = undef,
  $vlan                  = undef,
  $vlan_name_type        = undef,
  $vlan_id               = undef,
  $vid                   = undef,
  $physdev               = undef,
  $bridge                = undef,
  Optional[Enum['yes', 'no']] $arpcheck              = undef,
  $zone                  = undef,
  Optional[Enum['yes', 'no']] $arp                   = undef,
  Optional[Enum['yes', 'no']] $nozeroconf            = undef,
  $linkdelay             = undef,
  $check_link_down       = false,
  $hotplug               = undef,
  $persistent_dhclient   = undef,
  $nm_name               = undef,
  Optional[Array] $iprule                = undef,

  # RedHat specific for InfiniBand
  $connected_mode        = undef,

  # RedHat specific for GRE
  $peer_outer_ipaddr     = undef,
  $peer_inner_ipaddr     = undef,
  $my_outer_ipaddr       = undef,
  $my_inner_ipaddr       = undef,

  # RedHat and Debian specific for Open vSwitch
  $devicetype            = undef, # On RedHat. Same of ovs_type for Debian
  $bond_ifaces           = undef, # On RedHat Same of ovs_bonds for Debian
  $ovs_type              = undef, # Debian
  $ovs_bonds             = undef, # Debian
  $ovs_bridge            = undef,
  $ovs_ports             = undef,
  $ovs_extra             = undef,
  $ovs_options           = undef,
  $ovs_patch_peer        = undef,
  $ovsrequires           = undef,
  $ovs_tunnel_type       = undef,
  $ovs_tunnel_options    = undef,
  $ovsdhcpinterfaces     = undef,
  $ovsbootproto          = undef,

  # RedHat specific for zLinux
  Optional[Array] $subchannels           = undef,
  Optional[Enum['qeth', 'lcs', 'ctc']] $nettype               = undef,
  Optional[Enum['0', '1']] $layer2                = undef,
  Optional[String] $zlinux_options        = undef,

  ## Suse specific
  $startmode             = '',
  $usercontrol           = 'no',
  $firewall              = undef,
  $aliases               = undef,
  $remote_ipaddr         = undef,
  Optional[Enum['yes', 'no']] $check_duplicate_ip    = undef,
  Optional[Enum['yes', 'no']] $send_gratuitous_arp   = undef,
  $pre_up_script         = undef,
  $post_up_script        = undef,
  $pre_down_script       = undef,
  $post_down_script      = undef,

  # For bonding
  $bond_moduleopts       = undef,
  # also used for Suse bonding: $bond_master, $bond_slaves

  # For bridging
  $bridge_fwddelay       = undef,
  # also used for Suse bridging: $bridge, $bridge_ports, $bridge_stp

  # For vlan
  $etherdevice           = undef,
  # also used for Suse vlan: $vlan

  ) {

  include ::network

  if $facts['os']['family'] != 'RedHat' and ($type == 'InfiniBand' or $connected_mode) {
    fail('InfiniBand parameters are supported only for RedHat family.')
  }

  if $type != 'InfiniBand' and $connected_mode != undef {
    fail('CONNECTED_MODE parameter available for InfiniBand interfaces only')
  }

  if $prefix != undef and $netmask != undef {
    fail('Use either netmask or prefix to define the netmask for the interface')
  }

  if $hwaddr != undef and $macaddr != undef {
    fail('HWADDR and MACADDR cannot be used together')
  }

  $manage_method = $method ? {
    ''     => $enable_dhcp ? {
      true  => 'dhcp',
      false => 'static',
    },
    default => $method,
  }

  # Debian specific
  case $manage_method {
    'auto': { $manage_address = undef }
    'bootp': { $manage_address = undef }
    'dhcp': { $manage_address = undef }
    'ipv4ll': { $manage_address = undef }
    'loopback': { $manage_address = undef }
    'manual': { $manage_address = undef }
    'none': { $manage_address = undef }
    'ppp': { $manage_address = undef }
    'wvdial': { $manage_address = undef }
    default: {
      $manage_address = $my_inner_ipaddr ? {
        undef     => $address ? {
          ''      => $ipaddress,
          default => $address,
        },
        default   => $my_inner_ipaddr,
      }
    }
  }

  # Redhat and Suse specific
  if $facts['os']['name'] == 'SLES' and versioncmp($facts['os']['release'], '12') >= 0 {
    $bootproto_false = 'static'
  } else {
    $bootproto_false = 'none'
  }

  $manage_bootproto = $bootproto ? {
    ''     => $enable_dhcp ? {
      true  => 'dhcp',
      false => $bootproto_false
    },
    default => $bootproto,
  }
  $manage_peerdns = $peerdns ? {
    ''     => $manage_bootproto ? {
      'dhcp'  => 'yes',
      default => 'no',
    },
    true    => 'yes',
    false   => 'no',
    default => $peerdns,
  }
  $manage_peerntp = $peerntp ? {
    ''     => $manage_bootproto ? {
      'dhcp'  => 'yes',
      default => 'no',
    },
    default => $peerntp,
  }
  case $ipaddr {
    '': {
      $manage_ipaddr = $ipaddress
      $manage_prefix = $prefix
    }
    default: {
      if $ipaddr =~ /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\/([0-9]|[1-2][0-9]|3[0-2])$/ {
        $manage_ipaddr = $1
        $manage_prefix = $2
      } else {
        $manage_ipaddr = $ipaddr
        $manage_prefix = $prefix
      }
    }
  }
  $manage_onboot = $onboot ? {
    ''     => $enable ? {
      true   => 'yes',
      false  => 'no',
    },
    default => $onboot,
  }
  $manage_defroute = $defroute ? {
    true    => 'yes',
    false   => 'no',
    default => $defroute,
  }
  $manage_startmode = $startmode ? {
    ''     => $enable ? {
      true   => 'auto',
      false  => 'off',
    },
    default => $startmode,
  }

  # Resources
  $real_reload_command = $reload_command ? {
    undef => $facts['os']['name'] ? {
        'CumulusLinux' => 'ifreload -a',
        'RedHat'       => $facts['os']['release']['major'] ? {
          '8'     => "/usr/bin/nmcli con reload ; /usr/bin/nmcli device reapply ${interface}",
          default => "ifdown ${interface} --force ; ifup ${interface}",
        },
        default        => "ifdown ${interface} --force ; ifup ${interface}",
      },
    default => $reload_command,
  }
  if $restart_all_nic == false and $::kernel == 'Linux' {
    exec { "network_restart_${name}":
      command     => $real_reload_command,
      path        => '/sbin:/bin:/usr/sbin:/usr/bin',
      refreshonly => true,
    }
    $network_notify = "Exec[network_restart_${name}]"
  } else {
    $network_notify = $network::manage_config_file_notify
  }

  case $facts['os']['family'] {

    'Debian': {
      if $vlan_raw_device {
        if versioncmp('9.0', $facts['os']['release']) >= 0
        and !defined(Package['vlan']) {
          package { 'vlan':
            ensure => 'present',
          }
        }
      }

      if $network::config_file_per_interface {
        if ! defined(File['/etc/network/interfaces.d']) {
          file { '/etc/network/interfaces.d':
            ensure => 'directory',
            mode   => '0755',
            owner  => 'root',
            group  => 'root',
          }
        }
        if $facts['os']['name'] == 'CumulusLinux' {
          file { "interface-${name}":
            ensure  => $ensure,
            path    => "/etc/network/interfaces.d/${name}",
            content => template($template),
            notify  => $network_notify,
          }
          if ! defined(File_line['config_file_per_interface']) {
            file_line { 'config_file_per_interface':
              ensure => $ensure,
              path   => '/etc/network/ifupdown2/ifupdown2.conf',
              line   => 'addon_scripts_support=1',
              match  => 'addon_scripts_suppor*',
              notify => $network_notify,
            }
          }
        } else {
          file { "interface-${name}":
            ensure  => $ensure,
            path    => "/etc/network/interfaces.d/${name}.cfg",
            content => template($template),
            notify  => $network_notify,
          }
          if ! defined(File_line['config_file_per_interface']) {
            file_line { 'config_file_per_interface':
              ensure => $ensure,
              path   => '/etc/network/interfaces',
              line   => 'source /etc/network/interfaces.d/*',
              notify => $network_notify,
            }
          }
        }
        File['/etc/network/interfaces.d']
        -> File["interface-${name}"]
      } else {
        if ! defined(Concat['/etc/network/interfaces']) {
          concat { '/etc/network/interfaces':
            mode  => '0644',
            owner => 'root',
            group => 'root',
          }
        }

        concat::fragment { "interface-${name}":
          target  => '/etc/network/interfaces',
          content => template($template),
          order   => $manage_order,
        }

        if $restart_all_nic == true and $network::manage_config_file_notify != undef {
          Concat['/etc/network/interfaces'] ~> Exec['network_restart']
        } else {
          Concat['/etc/network/interfaces'] ~> Exec <| title == "network_restart_${name}" |>
        }
      }

      if ! defined(Network::Interface['lo']) {
        network::interface { 'lo':
          address         => '127.0.0.1',
          method          => 'loopback',
          manage_order    => '05',
          restart_all_nic => $restart_all_nic,
        }
      }
    }

    'RedHat': {
      if versioncmp($facts['os']['release']['major'], '8') >= 0 {
        if ! defined(Service['NetworkManager']) {
          service { 'NetworkManager':
            ensure => running,
            enable => true,
          }
        }
      }
      file { "/etc/sysconfig/network-scripts/ifcfg-${name}":
        ensure  => $ensure,
        content => template($template),
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        notify  => $network_notify,
      }
    }

    'Suse': {
      if $vlan {
        if !defined(Package['vlan']) {
          package { 'vlan':
            ensure => 'present',
          }
        }
        Package['vlan']
        -> File["/etc/sysconfig/network/ifcfg-${name}"]
      }
      if $bridge {
        if !defined(Package['bridge-utils']) {
          package { 'bridge-utils':
            ensure => 'present',
          }
        }
        Package['bridge-utils']
        -> File["/etc/sysconfig/network/ifcfg-${name}"]
      }

      file { "/etc/sysconfig/network/ifcfg-${name}":
        ensure  => $ensure,
        content => template($template),
        mode    => '0600',
        owner   => 'root',
        group   => 'root',
        notify  => $network_notify,
      }
    }

    'Solaris': {
      if $facts['os']['release'] == '5.11' {
        if ! defined(Service['svc:/network/physical:nwam']) {
          service { 'svc:/network/physical:nwam':
            ensure => stopped,
            enable => false,
            before => [
              Service['svc:/network/physical:default'],
              Exec["create ipaddr ${title}"],
              File["hostname iface ${title}"],
            ],
          }
        }
      }
      case $facts['os']['release']['major'] {
        '11','5': {
          if $enable_dhcp {
            $create_ip_command = "ipadm create-addr -T dhcp ${title}/dhcp"
            $show_ip_command = "ipadm show-addr ${title}/dhcp"
          } else {
            $create_ip_command = "ipadm create-addr -T static -a ${ipaddress}/${netmask} ${title}/v4static"
            $show_ip_command = "ipadm show-addr ${title}/v4static"
          }
        }
        default: {
          $create_ip_command = 'true '
          $show_ip_command = 'true '
        }
      }
      exec { "create ipaddr ${title}":
        command => $create_ip_command,
        unless  => $show_ip_command,
        path    => '/bin:/sbin:/usr/sbin:/usr/bin:/usr/gnu/bin',
        tag     => 'solaris',
      }
      file { "hostname iface ${title}":
        ensure  => file,
        path    => "/etc/hostname.${title}",
        content => inline_template("<%= @ipaddress %> netmask <%= @netmask %>\n"),
        require => Exec["create ipaddr ${title}"],
        tag     => 'solaris',
      }
      host { $facts['networking']['fqdn']:
        ensure       => present,
        ip           => $ipaddress,
        host_aliases => [$facts['networking']['hostname']],
        require      => File["hostname iface ${title}"],
      }
      if ! defined(Service['svc:/network/physical:default']) {
        service { 'svc:/network/physical:default':
          ensure    => running,
          enable    => true,
          subscribe => [
            File["hostname iface ${title}"],
            Exec["create ipaddr ${title}"],
          ],
        }
      }
    }

    default: {
      alert("${facts['os']['name']} not supported. No changes done here.")
    }

  }

}
